#!/bin/bash
#
# Checks for and creates bare git repositories

set -o nounset

main() {
    echo "git repos: ${GIT_REPOS:?git repos must be provided. See ${0} -h for usage message}"

    IFS=',' read -r -a repos <<< "${GIT_REPOS}"

    git config --global init.defaultBranch main

    local -a initialized_repos=()
    for r in ${repos[@]}; do
        if [[ ! -d $r ]]; then
            echo "$r doesn't exist, creating now"
            mkdir -p "$r"
        fi
        exists="$(git -C ${r} rev-parse --is-bare-repository)"
        if [[ $exists == "true" ]] ; then
            echo "not touching $r, is already a bare git repository"
        else
            pushd "$r" || abort "failed to cd into $r"
            if git init --bare; then
                initialized_repos+=("$r")
            fi
            popd || abort "failed to popd out of stack"
        fi
    done

    if [[ ${#initialized_repos[@]} -gt 0 ]]; then
        echo "Initialized repos: ${initialized_repos[*]}"
    fi
}

#######################################
# abort echos a message and exits with code 1
#######################################
abort() {
    echo "${1}, Aborting."
    exit 1
}

usage() {
    echo -e "USAGE:
    ./${0} -d </var/git/repo1>

ARGS:
    -d          Comma seperate list of git repository directories
    -h          This help message

EXAMPLES:
    ./${0} -d /var/git/repo1

    Multiple repos can be passed with commas seperating directories

    ./${0} -d /var/git/repo1,/var/git/repo2,/var/git/repo3
"

    exit "${1:-0}"
}

if [ -z "$*" ]; then
    abort "Directories must be supplied"
fi

while getopts "hd:" o; do
    case "${o}" in
    d)
        GIT_REPOS="${OPTARG}"
        ;;
    h)
        usage 0
        ;;
    *)
        usage 1
        ;;
    esac
done

main "$@"
