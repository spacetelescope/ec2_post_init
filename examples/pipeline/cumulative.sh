#!/usr/bin/env bash
source $ec2pinit_root/ec2pinit.inc.sh

# Update system packages
sys_pkg_update_all

# Install additional packages
if (( $HAVE_DNF )) || (( $HAVE_YUM )); then
    sys_pkg_install \
        gcc \
        bzip2-devel \
        curl \
        gcc \
        gcc-c++ \
        gcc-gfortran \
        git \
        glibc-devel \
        kernel-devel \
        libX11-devel \
        mesa-libGL \
        mesa-libGLU \
        ncurses-devel \
        openssh-server \
        subversion \
        sudo \
        wget \
        zlib-devel \
        xauth \
        xterm
#elif (( $HAVE_APT )); then
#    sys_pkg_install \
#        debian \
#        based \
#        packages here
fi

# "become" the target user
sys_user_push ec2-user

miniconda_root=$HOME/miniconda3
miniconda_version="py39_4.11.0"
export CFLAGS="-std=gnu99"

# Install miniconda
mc_install "$miniconda_version" "$miniconda_root" || true
mc_initialize "$miniconda_root"

# Install HST pipeline
ac_releases_install_hst "stable"

# Install JWST pipeline
ac_releases_install_jwst "1.5.2"

# Handle recently introduced packaging bug 05/2022 (old upstream tag deleted)
sed -i 's/hsluv.*/hsluv==5.0.3/' $ac_releases_path/de/$version_data_analysis/*.yml

# Install 
ac_releases_install_data_analysis "f"

# Clean up conda packages and caches
mc_clean

# return to root user
sys_user_pop

# Reset target user's home directory permissions
sys_reset_home_ownership ec2-user

# Clean up package manager
sys_pkg_clean
