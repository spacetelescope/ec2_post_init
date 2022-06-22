if (( $EUID > 0 )) || ! (( $DANGEROUS_TESTS )); then
    exit 0
fi

# I'm marking these as dangerous because they modify the host system in
# generally undesirable ways:
#   - Adding a profile script
#   - Adding users to groups
#   - Removing groups from users
#   - Exposing the docker API port to the system
#
# I recommend using vagrant or some one-off virtual machine for this suite

oneTimeSetUp() {
    source ec2pinit.inc.sh
    mkdir -p "$ec2pinit_tempdir"/home/tester
    export HOME_ORIG="$HOME"
    export HOME="$ec2pinit_tempdir"/home/tester
    export USER="root"
}

test_docker_setup_account_only() {
    docker_setup "$USER"
    pid=$(pgrep docker)
    assertTrue "Docker is not running" '[[ -n $pid ]] && [[ $pid =~ [0-9]+ ]]'
    docker ps &>/dev/null
    retval=$?
    assertTrue "$USER cannot use docker" '[ $retval -eq 0 ]'
}

test_docker_setup_bind_port() {
    if ! groups "$USER" | grep docker; then
        usermod -G "$(groups ${USER} | awk -F':' '{ print $2 }' | sed 's/^ //;s/docker//')" "$USER"
    fi
    docker_setup "" 2376
    pid=$(pgrep docker)
    assertTrue "Docker is not running" '[[ -n $pid ]] && [[ $pid =~ [0-9]+ ]]'
    docker ps &>/dev/null
    retval=$?
    assertTrue "$USER cannot use docker" '[ $retval -eq 0 ]'
}

test_docker_user_add() {
    docker_user_add "$USER" 1>/dev/null
    assertTrue "$USER was not added to docker group" 'groups $USER | grep docker'
}

test_docker_pull_many() {
    images=(centos:7 centos:8)
    docker_pull_many "${images[@]}"
    retval=$?
    assertTrue "Failed to pull images" '[ $retval -eq 0 ]'
}


. "$shunit_path"/shunit2
