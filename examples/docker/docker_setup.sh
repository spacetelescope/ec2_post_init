#!/usr/bin/env bash
source $ec2pinit_root/ec2pinit.inc.sh

docker_setup "$USER"
docker_pull_many "centos:7" "centos:8"

for version in {7..8}; do
    docker run --rm -it centos:${version} \
        /bin/sh -c 'echo hello world from $(cat /etc/redhat-release)'
done
