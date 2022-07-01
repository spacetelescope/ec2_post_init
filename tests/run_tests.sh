#!/usr/bin/env bash

if ! type -p git; then
    echo "Missing package: git"
    exit 1
fi

# Always test the source tree
export PATH="$(realpath ../bin):$PATH"
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
    for f in test_*.sh; do
        scripts+=("$f")
    done
fi

for f in "${scripts[@]}"; do
    echo "Running tests for: ${f}"
    if ! bash "$f"; then
        (( failures++ ))
    fi
done

if (( $failures )); then
    echo "Test suite(s) failed: $failures" >&2
    exit 1
fi
