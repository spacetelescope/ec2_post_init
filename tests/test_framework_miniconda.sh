oneTimeSetUp() {
    source ec2pinit.inc.sh
    mkdir -p "$ec2pinit_tempdir"/home
    export HOME_ORIG="$HOME"
    export HOME="$ec2pinit_tempdir"/home/tester
    cp -a /etc/skel $HOME || mkdir -p $HOME
    dest="$HOME"/miniconda3
    version="latest"
}

test_mc_get() {
    mc_get "$version" 1>/dev/null
    retval=$?
    installer="$ec2pinit_tempdir/$mc_installer"
    assertTrue "download failed" '[ $retval -eq 0 ]'
    assertTrue "$installer was not created" '[ -f "$installer" ]'
}

test_mc_install() {
    mc_install "$version" "$dest" 1>/dev/null
    retval=$?
    assertTrue "installation failed" '[ $retval -eq 0 ]'
    assertTrue "$dest was not created" '[ -d "$dest"/bin ]'
}

test_mc_initialize() {
    mc_initialize "$dest" 1>/dev/null
    assertTrue "unexpected path to conda: $CONDA_EXE" '[[ "$dest"/bin/conda == "$CONDA_EXE" ]]'
}

test_mc_configure_defaults() {
    mc_configure_defaults 1>/dev/null
    keys=(
        auto_update_conda
        always_yes
        report_errors
    )
    for key in "${keys[@]}"; do
        assertNotNull 'conda configuration key not set: $key' '$(conda config --get $key)'
    done
}

test_mc_clean() {
    mc_clean 1>/dev/null
    retval=$?
    assertTrue "clean operation failed" '[ $retval -eq 0 ]'
}

. "$shunit_path"/shunit2
