## @file
## @brief Framework entrypoint
##
## Include this file in your script to use ec2pinit's functions
##
## @mainpage
## @section intro_sec Introduction
##
## This library is useful if you are not a systems administrator by trade yet been handed the daunting task of provisioning EC2 images to do data analysis or research. ec2_post_init provides a clean, easy to use API to install STScI software pipelines and system software.
## 
## @section require_sec Supported Operating Systems
##
## - Red Hat
##   - CentOS 7+
##   - Fedora 19+
## - Debian
##
## @section install_sec Installation
##
## @code{.sh}
## git clone https://github.com/spacetelescope/ec2_post_init
## cd ec2_post_init
## sudo make install PREFIX=/usr/local
## @endcode
##
## @section usage_sec Using ec2_post_init
##
## Now you can include the library in your own script by sourcing ``ec2pinit.inc.sh``...
##
## @code{.sh}
## #!/usr/bin/env bash
##
## # Load ec2_post_init
## source ec2pinit.inc.sh
##
## # ...
## @endcode
##
## @section example_sec Full Example
##
## @include cumulative.sh
##
## @page license_page License
## @include LICENSE.txt

(( $EC2PINIT_INCLUDED )) && return
EC2PINIT_INCLUDED=1

## @property ec2pinit_root
## @brief Path to ec2pinit directory
##
## Do not change this value
ec2pinit_root="$(readlink -f $(dirname ${BASH_SOURCE[0]})/..)"
export ec2pinit_root

## @property ec2pinit_framework
## @brief Path to framework directory
##
## Do not change this value
ec2pinit_framework="$ec2pinit_root"/framework
export ec2pinit_framework

## @property ec2pinit_tempdir
## @brief Where ec2pinit will store temporary data
##
## Do not change this value
ec2pinit_tempdir=/tmp/ec2_post_init
export ec2pinit_tempdir

## FLAG - Print info messages
DEBUG_INFO=$(( 1 << 1 ))
export DEBUG_INFO

## FLAG - Print warning messages
DEBUG_WARN=$(( 1 << 2 ))
export DEBUG_WARN

## FLAG - Print error messages
DEBUG_ERROR=$(( 1 << 3 ))
export DEBUG_ERROR

## FLAG - Print only warnings and errors
DEBUG_DEFAULT=$(( DEBUG_WARN | DEBUG_ERROR ))
export DEBUG_DEFAULT

## FLAG - Print all messages
DEBUG_ALL=$(( DEBUG_INFO | DEBUG_WARN | DEBUG_ERROR ))
export DEBUG_ALL

## @property ec2pinit_debug
## @brief Debug output control
## 
## Set print statement behavior with: ``DEBUG_INFO``, ``DEBUG_WARN``, and ``DEBUG_ERROR``
## @code{.sh}
## ec2pinit_debug=$(( DEBUG_WARN | DEBUG_ERROR ))
## @endcode
ec2pinit_debug=${ec2pinit_debug:-$DEBUG_DEFAULT}
export ec2pinit_debug

# If the user modifies debug flags through the environment
# verify an integer was received. If not then use the defaults
if ! [[ "$ec2pinit_debug" =~ [0-9]+ ]]; then
    # pre-IO function availability
    echo "WARN: ec2pinit_debug: Must be a positive integer!" >&2
    echo "WARN: Using DEBUG_DEFAULT ($DEBUG_DEFAULT)." >&2
    ec2pinit_debug=$DEBUG_DEFAULT
fi

mkdir -p "$ec2pinit_tempdir"
source $ec2pinit_framework/io.inc.sh
source $ec2pinit_framework/system.inc.sh
source $ec2pinit_framework/miniconda.inc.sh
source $ec2pinit_framework/astroconda.inc.sh
source $ec2pinit_framework/docker.inc.sh
