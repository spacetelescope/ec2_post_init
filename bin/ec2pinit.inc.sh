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
##   - Stretch+
## - Ubuntu
##   - Bionic+
##
## @section install_sec Installing
##
## @subsection install_system_subsec System installation
##
## @code{.sh}
## git clone https://github.com/spacetelescope/ec2_post_init
## cd ec2_post_init
## sudo make install PREFIX=/usr/local
## @endcode
##
## @subsection install_portable_subsec Portable installation
##
## If you don't want to install ec2_post_init permanently, you don't have to. This is especially useful for systems that provide ``curl`` and ``tar`` by default but lack ``git`` and ``make``. Here is how to use ec2_post_init from its source directory:
##
## @code{.sh}
## curl https://github.com/spacetelescope/ec2_post_init/archive/refs/heads/main.tar.gz | tar -x
## cd ec2_post_init
## export PATH=$(pwd)/bin:$PATH
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
## @section install_develop_sec Developing
##
## To write code for ec2_post_init you should have access to an EC2 instance, or a host with ``docker`` or ``vagrant`` installed.
##
## @code{.sh}
## git clone https://github.com/spacetelescope/ec2_post_init
## cd ec2_post_init
## export PATH=$(pwd)/bin:$PATH
## @endcode
##
## To test ec2_post_init using docker:
##
## @code{.sh}
## docker run --rm -it -v $(pwd):/data -w /data centos:7 /bin/bash
## [root@abc123 data]# export PATH=$PATH:/data/bin
## [root@abc123 data]# cd tests
## [root@abc123 tests]# ./run_tests.sh
## @endcode
##
## To test ec2_post_init using vagrant (VirtualBox):
##
## @code{.sh}
## mkdir -p ~/vagrant/centos/7
## cd ~/vagrant/centos/7
## @endcode
##
## Create a new ``Vagrantfile``. Be sure to change any paths to match your local system
##
## @code
## Vagrant.configure("2") do |config|
##   config.vm.box = "generic/centos7"
##
##   # Mount the ec2_post_init source directory at /data inside of the VM
##   config.vm.synced_folder "/home/example/my_code/ec2_post_init", "/data"
##
##   # Change VM resources
##   config.vm.provider "virtualbox" do |v|
##     v.memory = 2048
##     v.cpus = 2
##   end
## end
## @endcode
##
## Provision the VM, log in, and execute the test suite:
##
## @code{.sh}
## vagrant up
## vagrant ssh sudo -i
## [root@vagrant123 ~]# export PATH=$PATH:/data/bin
## [root@vagrant123 data]# cd /data/tests
## [root@vagrant123 tests]# ./run_tests.sh
## @endcode
##
## @page full_example_page Full example
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

# Adjust the framework path when we're installed as a system package
if [ ! -d "$ec2pinit_framework" ]; then
    ec2pinit_framework="$ec2pinit_root/share/ec2_post_init"/framework
fi
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

bug_report() {
    io_error "$*"
    io_error "Please open an issue at: https://github.com/spacetelescope/ec2_post_init"
    echo
    echo TYPE
    echo ====
    ([ -f /.dockerenv ] && echo Docker) || echo 'Physical / Virtualized'
    echo
    echo KERNEL
    echo ======
    uname -a
    echo
    echo MEMORY
    echo ======
    command free -m
    echo
    echo CPU
    echo ===
    lscpu
    echo
    echo EC2_POST_INIT INFO
    echo ==================
    set | grep -E '^(ec2pinit|EC2PINIT|ec2_post_init|HAVE_|HOME|USER|PWD|sys_manager_)' | sort
    echo
    echo
}

mkdir -p "$ec2pinit_tempdir"
source $ec2pinit_framework/io.inc.sh
source $ec2pinit_framework/system.inc.sh

# OS detection gate
if (( ! HAVE_SUPPORT )); then
    bug_report "OPERATING SYSTEM IS NOT SUPPORTED"
    false
    return
else
    if ! sys_initialize; then
        bug_report "UNABLE TO INITIALIZE BASE OPERATING SYSTEM PACKAGES"
        false
        return
    fi
fi

source $ec2pinit_framework/miniconda.inc.sh
source $ec2pinit_framework/astroconda.inc.sh
source $ec2pinit_framework/docker.inc.sh

# Ensure any external success checks succeed
true
return
