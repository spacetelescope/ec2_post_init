## @file
## @brief ec2pinit configuration file

# Constants

## Path to ec2pinit directory
##
## Do not change this value
ec2pinit_root="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
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

# Site variables

## URL to astroconda releases Git repository (or local file system)
##
ac_releases_repo="https://github.com/astroconda/astroconda-releases"
export ac_releases_repo

## Path where ec2pinit will store the astroconda releases repository
##
ac_releases_path="$ec2pinit_tempdir/$(basename $ac_releases_repo)"
export ac_releases_path

## URL to a site providing miniconda installers
##
mc_url="https://repo.anaconda.com/miniconda"
export mc_url

## Path where the miniconda3 installer will be stored
##
mc_installer="$ec2pinit_tempdir/mc_installer.sh"
export mc_installer
