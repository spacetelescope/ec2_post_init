#!/usr/bin/env bash
source $ec2pinit_root/ec2pinit.inc.sh

# Update system packages
sys_pkg_update_all

# Install additional packages
sys_pkg_install curl \
    gcc \
    git \
    sudo

# "become" the target user
sys_user_push ec2-user

miniconda_root=$HOME/miniconda3
miniconda_version="py39_4.12.0"

# Install miniconda
mc_install "$miniconda_version" "$miniconda_root"

# Configure miniconda for user
mc_initialize "$miniconda_root"

# Install JWST pipeline release
export CFLAGS="-std=gnu99"
ac_releases_install_jwst "1.5.2"

# Return to root user
sys_user_pop

# Reset target user's home directory permissions
sys_reset_home_ownership ec2-user
