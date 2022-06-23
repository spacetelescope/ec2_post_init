#!/usr/bin/env bash
source ec2pinit.inc.sh

setUp() {
    output="DEBUG LEVEL: "
    re_stamp='([0-9]+)-([0-9]+)-([0-9]+)\ ([0-9]+):([0-9]+):([0-9]+)\ -\'
}

tearDown() {
    ec2pinit_debug=0
}

test_io_info() {
    ec2pinit_debug=$(( DEBUG_INFO ))
    io_info "$output $ec2pinit_debug" 2>&1 | grep -E "$re_stamp INFO: $output .*"
}

test_io_warn() {
    ec2pinit_debug=$(( DEBUG_WARN ))
    io_warn "$output $ec2pinit_debug" 2>&1 | grep -E "$re_stamp WARN: $output .*"
}

test_io_error() {
    ec2pinit_debug=$(( DEBUG_ERROR ))
    io_error "$output $ec2pinit_debug" 2>&1 | grep -E "$re_stamp ERROR: $output .*"
}

test_io_DEBUG_ALL() {
    ec2pinit_debug=$(( DEBUG_ALL ))
    (io_info "YES"; io_warn "YES"; io_error "YES") 2>&1 | grep -E "$re_stamp (INFO|WARN|ERROR): YES"
}

. "$shunit_path"/shunit2
