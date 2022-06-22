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
## ec2_post_init is designed to be included from anywhere on the file system as long as the original directory structure is preserved. If you plan to install this library globally for everyone to use I suggest copying the source directory to ``/usr/libexec/ec2_post_init`` or ``/usr/share/ec2_post_init``.
##
## @subsection step1 Clone the repository
## @code{.sh}
## git clone https://github.com/spacetelescope/ec2_post_init
## @endcode
##
## @section usage_sec Usage
##
## To begin using the ec2_post_init library in your own script, source ``ec2pinit.inc.sh`` from the project's root directory.
##
## ``my_script.sh``:
##
## @code{.sh}
## #!/usr/bin/env bash
##
## # Load ec2_post_init library
## source ec2_post_init/ec2pinit.inc.sh
##
## # ...
## @endcode
##
## @section example_sec Full Example
## @include cumulative.sh
## @example cumulative.sh
##

(( $EC2PINIT_INCLUDED )) && return
EC2PINIT_INCLUDED=1
source $ec2pinit_root/config.sh
mkdir -p "$ec2pinit_tempdir"
source $ec2pinit_framework/system.inc.sh
source $ec2pinit_framework/miniconda.inc.sh
source $ec2pinit_framework/astroconda.inc.sh
source $ec2pinit_framework/docker.inc.sh
