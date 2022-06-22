## @file
## @brief Input output functions

(( $EC2PINIT_IO_INCLUDED )) && return
EC2PINIT_IO_INCLUDED=1
source ec2pinit.inc.sh

io_date="%Y-%m-%d %H:%M:%S"

io_timestamp() {
    date +"$io_date"
}

io_info() {
    (( ec2pinit_debug > 1 )) || return
    printf "$(io_timestamp) - INFO: %s\n" "$@" >&2
}

io_warn() {
    (( ec2pinit_debug )) || return
    printf "$(io_timestamp) - WARN: %s\n" "$@" >&2
}

io_error() {
    (( ! ec2pinit_debug )) || return
    printf "$(io_timestamp) - ERROR: %s\n" "$@" >&2
}
