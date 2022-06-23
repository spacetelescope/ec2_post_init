## @file
## @brief Input output functions

(( $EC2PINIT_IO_INCLUDED )) && return
EC2PINIT_IO_INCLUDED=1
source ec2pinit.inc.sh

## Date format for IO functions
##
io_datefmt="%Y-%m-%d %H:%M:%S"
export io_datefmt

## @fn io_timestamp()
## @brief Return current date and time
## @retval date as string
io_timestamp() {
    date +"$io_datefmt"
}

## @fn io_info()
## @brief Print a message
## @param ... message arguments
##
## @code{.sh}
## var=hello
## ec2pinit_debug=2
## io_info "$var"
## # 2022-06-22 18:46:57 - INFO: hello
## @endcode
io_info() {
    (( ec2pinit_debug & DEBUG_INFO )) || return
    printf "$(io_timestamp) - INFO: %s\n" "$@" >&2
}

## @fn io_warn()
## @brief Print a warning message
## @param ... message arguments
##
## @code{.sh}
## var=hello
## ec2pinit_debug=1
## io_warn "uh oh... $var"
## # 2022-06-22 18:46:57 - WARN: uh oh... hello
## @endcode
io_warn() {
    (( ec2pinit_debug & DEBUG_WARN )) || return
    printf "$(io_timestamp) - WARN: %s\n" "$@" >&2
}

## @fn io_error()
## @brief Print an error message
## @param ... message arguments
##
## @code{.sh}
## var=hello
## ec2pinit_debug=0
## io_error "oh no... $var"
## # 2022-06-22 18:46:57 - ERROR: oh no... hello
## @endcode
io_error() {
    (( ec2pinit_debug & DEBUG_ERROR )) || return
    printf "$(io_timestamp) - ERROR: %s\n" "$@" >&2
}
