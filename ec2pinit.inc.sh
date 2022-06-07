(( $EC2PINIT_INCLUDED )) && return
EC2PINIT_INCLUDED=1
source $ec2pinit_root/config.sh
mkdir -p "$ec2pinit_tempdir"
source $ec2pinit_framework/system.inc.sh
source $ec2pinit_framework/miniconda.inc.sh
source $ec2pinit_framework/astroconda.inc.sh
