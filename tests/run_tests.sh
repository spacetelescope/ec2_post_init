#!/usr/bin/env bash

if ! type -p git; then
    echo "Missing package: git"
    exit 1
fi

export shunit_path="$(pwd)/shunit"
[ ! -d "$shunit_path" ] && git clone https://github.com/kward/shunit2 "$shunit_path"

argv=($@)
argc=$#

if (( $argc > 0 )); then
    for (( i=0; i < $argc; i++ )); do
        [ -f "${argv[i]}" ] && [[ "${argv[i]}" =~ ^test_.*\.sh ]] && bash "${argv[i]}"
    done
else
    for test_script in test_*.sh; do
        echo "Running tests for: ${test_script}"
        bash "${test_script}"
        echo
    done
fi
