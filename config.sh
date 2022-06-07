# Constants
ec2pinit_root="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
export ec2pinit_root

ec2pinit_framework="$ec2pinit_root"/framework
export ec2pinit_framework

ec2pinit_tempdir=/tmp/ec2_post_init
export ec2pinit_tempdir

# Site variables
ac_releases_repo="https://github.com/astroconda/astroconda-releases"
ac_releases_path="$ec2pinit_tempdir/$(basename $ac_releases_repo)"

mc_url="https://repo.anaconda.com/miniconda"
mc_installer="$ec2pinit_tempdir/mc_installer.sh"
