(( $EC2PINIT_SYSTEM_INCLUDED )) && return
EC2PINIT_SYSTEM_INCLUDED=1
source $ec2pinit_root/ec2pinit.inc.sh

# System functions
_sys_user_old=''
_sys_user_home_old=''


## @fn sys_user_push()
## @brief Lazily "become" another user
## @details This sidesteps sudo's environment limitations allowing
## one to execute scripts on behalf of the named user. Anything modified
## while sys_user_push() is active will need to have its ownership and/or
## octal permissions normalized.
## @param name the user to become
sys_user_push() {
    local name="$1"
    local current="$(id -n -u)"
    _sys_user_home_old=$(sys_user_home $current)
    _sys_user_old=$current
    export HOME=$(sys_user_home $name)
    export USER=$name
    pushd $HOME
}

## @fn sys_user_pop()
## @brief Restore caller environment after sys_user_push()
sys_user_pop() {
    export HOME="$_sys_user_home_old"
    export USER="$_sys_user_old"
    export _sys_user_home_old=''
    export _sys_user_old=''
    popd
}

## @fn sys_platform()
## @retval platform string
sys_platform() {
    local result=$(uname -s)
    case "$result" in
        # placeholder - convert platform name to miniconda platform string
        *)
            ;;
    esac
    echo "$result"
}

## @fn sys_arch()
## @retval architecture string
sys_arch() {
    local result=$(uname -m)
    case "$result" in
        # placeholder - convert cpu architecture name to miniconda architecture string
        *) ;;  
    esac
    echo "$result"
}

## @fn sys_user_home()
## @param user account to inspect
## @retval home directory path
sys_user_home() {
    local user="${1:-$USER}"
    
    # short circuit - if the user is the one we're logged in as, return its home variable
    if [[ $(id -n -u) == "$user" ]]; then
        echo "$HOME"
        return
    fi
    getent passwd $user | awk -F: '{ print $6 }'
}

## @fn sys_reset_home_ownership()
## @brief Resets ownership of a user (after sys_user_[push/pop]())
## @param user account to modify
sys_reset_home_ownership() {
    local home
    local user="${1:-$USER}"

    if [ -z "$user" ]; then
        echo "sys_reset_home_ownership: user name required" >&2
        false
        return
    fi

    home="$(getent passwd $user | awk -F: '{ print $6 }')"
    if [ -z "$home" ]; then
        echo "sys_reset_home_ownership: reset failed" >&2
        false
        return
    fi

    chown -R "${user}": "${home}"
}


sys_pkg_get_manager() {
    local managers=(
        "dnf"
        "yum"
        "apt"
        "apt-get"
        ""
    )
    local result="";
    for manager in "${managers[@]}"; do
        local tmp=$(type -p $manager)
        if [ -x "$tmp" ]; then
            result="$tmp"
            break;
        fi
    done
    
    echo "$result"
}

# Configure package manager globals
sys_manager_cmd=$(sys_pkg_get_manager)
case "$(basename $sys_manager_cmd)" in
    dnf)
        HAVE_DNF=1
        sys_manager_cmd_install="dnf -y install"
        sys_manager_cmd_update="dnf -y update"
        sys_manager_cmd_clean="dnf clean all"
        sys_manager_cmd_list="rpm -qa"
        ;;
    yum)
        HAVE_YUM=1
        sys_manager_cmd_install="yum -y install"
        sys_manager_cmd_update="yum -y update"
        sys_manager_cmd_clean="yum clean all"
        sys_manager_cmd_list="rpm -qa"
        ;;
    apt)
        HAVE_APT=1
        DEBIAN_FRONTEND=noninteractive
        sys_manager_cmd_install="apt -y install"
        sys_manager_cmd_update="apt -y update && apt -y upgrade"
        sys_manager_cmd_clean="apt -y autoremove && apt -y clean"
        sys_manager_cmd_list="apt -qq list"
        ;;
esac

sys_pkg_install() {
    if (( "$#" < 1 )); then
        echo "sys_pkg_install: at least one package name is required" >&2
        false
        return
    fi
    $sys_manager_cmd_install $@
}

sys_pkg_update_all() {
    $sys_manager_cmd_update
}

sys_pkg_installed() {
    local output=''
    local name="$1"
    if (( "$#" < 1 )); then
        echo "sys_pkg_installed: package name is required" >&2
        false
        return
    fi

    output="$($sys_manager_cmd_list $name | tail -n 1)"
    if (( $HAVE_YUM )) || (( $HAVE_DNF )); then
        if grep -E ''^$1\..*'' <<< "$output" &>/dev/null; then
            true
            return
        fi
    elif (( $HAVE_APT )); then
        if grep -E ''^$1.*\[installed\]$'' <<< "$output" &>/dev/null; then
            true
            return
        fi
    fi

    false
    return
}

sys_pkg_clean() {
    $sys_manager_cmd_clean
}
