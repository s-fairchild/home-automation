#!/bin/bash
#
# Bash helper functions meant to be sourced and used externally

esformat() {
    echo "${1:?String to format must be provided}" | tr [:lower:] [:upper:] | sed s/_/__/g | tr . _ 
}
