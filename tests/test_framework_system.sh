ec2pinit_root=$(realpath ..)
if (( $EUID > 0 )); then
    not_root=1
fi

oneTimeSetUp() {
    source ec2pinit.inc.sh
    mkdir -p "$ec2pinit_tempdir"/home/tester
    export HOME_ORIG="$HOME"
    export HOME="$ec2pinit_tempdir"/home/tester
    export USER="root"
}

# this test is a no-op
test_sys_user_push() {
    (( $not_root )) && return
    sys_user_push "$USER" 1>/dev/null
    assertTrue "$HOME != $HOME_ORIG" '[[ $HOME != "$HOME_ORIG" ]]'
}

# this test is a no-op
test_sys_user_pop() {
    (( $not_root )) && return
    sys_user_pop 1>/dev/null
    assertTrue "$HOME != $HOME_ORIG" '[[ $HOME != "$HOME_ORIG" ]]'
}

test_sys_reset_home_ownership() {
    (( $not_root )) && return
    sys_reset_home_ownership $USER 1>/dev/null
    retval=$?
    assertTrue "Failed to reset ownership" '[ $retval -eq 0 ]'
}

test_sys_pkg_install() {
    (( $not_root )) && return
    pkg=nano
    sys_pkg_install $pkg 1>/dev/null
    retval=$?
    assertTrue "'$pkg' could not be installed" '[ $retval -eq 0 ]'

    sys_pkg_installed $pkg
    retval=$?
    assertTrue "'$pkg' not installed"  '[ $retval -eq 0 ]'
}

test_sys_pkg_clean() {
    (( $not_root )) && return
    sys_pkg_clean 1>/dev/null
    retval=$?
    assertTrue "Failed to clean up system packages" '[ $retval -eq 0 ]'
}

test_sys_pkg_update_all() {
    (( $not_root )) && return
    sys_pkg_update_all 1>/dev/null
    retval=$?
    assertTrue "failed to update system packages" '[ $retval -eq 0 ]'
}

test_sys_pkg_get_manager() {
    assertTrue "" '[[ -n $(sys_pkg_get_manager) ]]'
}

test_sys_user_home() {
    assertTrue "" '[[ -d $(sys_user_home root) ]]'
}

test_sys_arch() {
    assertTrue "" '[[ -n $(sys_arch) ]]'
}

test_sys_platform() {
    assertTrue "" '[[ -n $(sys_platform) ]]'
}

test_sys_pkg_installed() {
    sys_pkg_installed coreutils
    retval=$?
    assertTrue "coreutils not installed (unlikely!)"  '[ $retval -eq 0 ]'

    sys_pkg_installed samba
    retval=$?
    assertTrue "samba installed when it shouldn't be" '[ $retval -ne 0 ]'

    # No arguments
    assertFalse sys_pkg_installed
}

. "$shunit_path"/shunit2
