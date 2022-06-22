oneTimeSetUp() {
    source ec2pinit.inc.sh
    mkdir -p "$ec2pinit_tempdir"/home/tester
    export HOME_ORIG="$HOME"
    export HOME="$ec2pinit_tempdir"/home/tester
    dest="$HOME"/miniconda3
    version="latest"
}

test_ac_platform() {
    assertTrue '[ -n $(ac_platform) ]'
}

test_ac_releases_clone() {
    ac_releases_clone 1>/dev/null
    assertTrue '[ -d $ac_releases_path ]'
}

test_ac_releases_pipeline_exists() {
    path=$(ac_releases_pipeline_exists caldp)
    assertTrue '[ -d $path ]'
}

test_ac_releases_pipeline_release_exists() {
    path=$(ac_releases_pipeline_release_exists caldp stable)
    assertTrue '[ -d $path ]'
}

test_ac_releases_data_analysis() {
    path=$(ac_releases_data_analysis f)
    assertTrue '[ -f $path ]'

    path=$(ac_releases_data_analysis)
    assertTrue '[ -f $path ]'
}

test_ac_releases_data_analysis_environ() {
    path=$(ac_releases_data_analysis f)
    assertTrue '[ -n $(ac_releases_data_analysis_environ) ]'
}

test_ac_releases_jwst() {
    path=($(ac_releases_jwst 1.5.2))
    assertTrue '[ -f "${path[0]}" ]'
    assertTrue '[ -f "${path[1]}" ]'

    path=($(ac_releases_jwst))
    assertTrue '[ -f "${path[0]}" ]'
    assertTrue '[ -f "${path[1]}" ]'
}

test_ac_releases_jwst_environ() {
    path=$(ac_releases_jwst 1.5.2)
    assertTrue '[ -n $(ac_releases_jwst_environ $path) ]'
}

test_ac_releases_hst() {
    path=$(ac_releases_hst stable)
    assertTrue '[ -f $path ]'

    path=$(ac_releases_hst)
    assertTrue '[ -f $path ]'
}

test_ac_releases_hst_environ() {
    path=$(ac_releases_hst stable)
    assertTrue '[ -n $(ac_releases_hst_environ $path) ]'
}

# Full pipeline installations might fail due to external factors
# I need to create some mock configurations before I can continue writing these
test_ac_releases_install_hst() {
    true
}

test_ac_releases_install_jwst() {
    true
}

test_ac_releases_install_data_analysis() {
    true
}

. "$shunit_path"/shunit2
