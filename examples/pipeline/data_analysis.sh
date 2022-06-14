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
export CFLAGS="-std=gnu99"

# Install miniconda
mc_install "$miniconda_version" "$miniconda_root"

# Configure miniconda for user
mc_initialize "$miniconda_root"


# Fix recently introduced packaging bug 05/2022
ac_releases_clone
sed -i 's/hsluv.*/hsluv==5.0.3/' $ac_releases_path/de/f/*.yml

# Install Data Analysis pipeline release
ac_releases_install_data_analysis "f"

# Return to root user
sys_user_pop

# Reset target user's home directory permissions
sys_reset_home_ownership ec2-user
