oneTimeSetUp() {
    source ec2pinit.inc.sh
}

test_config() {
    assertNotNull "$ec2pinit_root"
    assertNotNull "$ec2pinit_framework"
    assertNotNull "$ec2pinit_tempdir"
    assertNotNull "$ac_releases_repo"
    assertNotNull "$ac_releases_path"
    assertNotNull "$mc_url"
    assertNotNull "$mc_installer"
}

test_config_directories() {
    assertTrue "root directory not found" '[ -d $ec2pinit_root ]'
    assertTrue "framework directory not found" '[ -d $ec2pinit_framework ]'
    assertTrue "$ec2pinit_tempdir is missing" '[ -d $ec2pinit_tempdir ]'
    assertTrue "$ec2pinit_tempdir is not writable" '[ -w $ec2pinit_tempdir ]'
    assertTrue "$ac_releases_path should not exist yet" '[ ! -d $ac_releases_path ]'
    assertTrue "$mc_installer should not exist yet" '[ ! -d $ac_releases_path ]'
}

test_config_upstream_connectivity() {
    assertTrue "$ac_releases_repo is broken" 'curl -f -S -L $ac_releases_repo'
    assertTrue "$mc_url is broken" 'curl -f -S -L $mc_url'
}

. "$shunit_path"/shunit2
