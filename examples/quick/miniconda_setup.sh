#!/usr/bin/env bash
source ec2pinit.inc.sh

# Download and install the "latest" release of miniconda3
mc_install "latest" "$HOME/miniconda3"

# Initialize miniconda3 (automatic conda init, conda config, etc)
mc_initialize "$HOME/miniconda3"

# Create a few basic environments
# Note: -y/--yes isn't required. "always_yes" is set to true by mc_initialize
conda create -n py39 python=3.9
conda create -n py310 python=3.10

# Save space. Clean up conda's caches
mc_clean
