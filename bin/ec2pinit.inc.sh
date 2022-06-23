## @file
## @brief Framework entrypoint
##
## Include this file in your script to use ec2pinit's functions

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
## sudo git clone https://github.com/spacetelescope/ec2_post_init /usr/share/ec2_post_init
## @endcode
##
## @section usage_sec Using ec2_post_init
##
## To begin using the library append ``ec2_post_init/bin`` to your ``PATH``
##
## @code{.sh}
## export PATH="$PATH:/usr/share/ec2_post_init/bin"
## @endcode
##
## And include it in your own script by sourcing ``ec2pinit.inc.sh``...
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
## @example cumulative.sh
##
## @page license_page License
## @include LICENSE.txt
##

(( $EC2PINIT_INCLUDED )) && return
EC2PINIT_INCLUDED=1

# Constants

## Path to ec2pinit directory
##
## Do not change this value
ec2pinit_root="$(readlink -f $(dirname ${BASH_SOURCE[0]})/..)"
export ec2pinit_root

## Path to framework directory
##
## Do not change this value
ec2pinit_framework="$ec2pinit_root"/framework
export ec2pinit_framework

## Where ec2pinit will store temporary data
##
## Do not change this value
ec2pinit_tempdir=/tmp/ec2_post_init
export ec2pinit_tempdir

## Debug output control
##
## ``0`` = errors
##
## ``1`` = warnings & errors
##
## ``2`` = information & warnings & errors
ec2pinit_debug=${ec2pinit_debug:-0}
export ec2pinit_debug

mkdir -p "$ec2pinit_tempdir"
source $ec2pinit_framework/io.inc.sh
source $ec2pinit_framework/system.inc.sh
source $ec2pinit_framework/miniconda.inc.sh
source $ec2pinit_framework/astroconda.inc.sh
source $ec2pinit_framework/docker.inc.sh
