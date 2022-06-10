#!/usr/bin/env bash

if ! type -p git; then
    echo "Missing package: git"
    exit 1
fi

export shunit_path="$(pwd)/shunit"
[ ! -d "$shunit_path" ] && git clone https://github.com/kward/shunit2 "$shunit_path"

argv=($@)
argc=$#
scripts=()
failures=0

if (( $argc > 0 )); then
    for (( i=0; i < $argc; i++ )); do
        if [ -f "${argv[i]}" ] && [[ "${argv[i]}" =~ ^test_.*\.sh ]]; then
            scripts+=("${argv[i]}")
        fi
    done
else
    for test_script in test_*.sh; do
        echo "Running tests for: ${test_script}"
        scripts+=("${argv[i]}")
        echo
    done
fi

for test_script in "${scripts[@]}"; do
    if bash "$test_script"; then
        (( failures++ ))
    fi
done

if (( $failures )); then
    echo "Failure(s): $failures" >&2
    exit 1
fi
