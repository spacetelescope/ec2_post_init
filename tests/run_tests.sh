#!/usr/bin/env bash

export shunit_path="$(pwd)/shunit"
[ ! -d "$shunit_path" ] && git clone https://github.com/kward/shunit2 "$shunit_path"

for test_script in test_*.sh; do
    echo "Running tests for: ${test_script}"
    bash "${test_script}"
    echo
done
