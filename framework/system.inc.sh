## @file
## @brief System functions

(( $EC2PINIT_SYSTEM_INCLUDED )) && return
EC2PINIT_SYSTEM_INCLUDED=1
source ec2pinit.inc.sh

_sys_user_old=''
_sys_user_home_old=''

## System uses DNF package manager
export HAVE_DNF=0

## System uses YUM package manager
export HAVE_YUM=0

## System uses APT package manager
export HAVE_APT=0

## System is based on Red Hat
export HAVE_REDHAT=0

## System is based on Debian
export HAVE_DEBIAN=0

## System is based on Ubuntu
export HAVE_UBUNTU=0

## System is based on Arch
export HAVE_ARCH=0

## System is supported
export HAVE_SUPPORT=1

## @fn sys_user_push()
## @brief Lazily "become" another user
## @details This sidesteps sudo's environment limitations allowing
## one to execute scripts on behalf of the named user. Anything modified
## while sys_user_push() is active will need to have its ownership and/or
## octal permissions normalized. If ``name`` does not exist it will be created.
## @param name the user to become
sys_user_push() {
    local name="$1"
    local current="$(id -n -u)"
    _sys_user_home_old=$(sys_user_home $current)
    _sys_user_old=$current
    HOME=$(sys_user_home $name)
    if [ -z "$HOME" ]; then
        useradd -m -s /bin/bash "$name"
        HOME=/home/"$name"
    fi
    export USER=$name
    pushd "$HOME"
}

## @fn sys_user_pop()
## @brief Restore caller environment after sys_user_push()
sys_user_pop() {
    HOME="$_sys_user_home_old"
    export USER="$_sys_user_old"
    export _sys_user_home_old=''
    export _sys_user_old=''
    popd
}

## @fn sys_platform()
## @brief Get system platform (``Linux``, ``Darwin``, etc)
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
## @brief Get system architecture (``i386``, ``x86_64``, etc)
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
## @brief Get account home directory
## @details This function returns the home directory defined in /etc/passwd unless 
## ``name`` is the caller's account; in which case it will use the value of ``$HOME``. 
## @param user account to inspect
## @retval home directory path
sys_user_home() {
    local user="${1:-$USER}"
    
    if [ -z "$user" ]; then
        user=$(id -n -u)
    fi

    # short circuit - if the user is the one we're logged in as, return its home variable
    if [[ $(id -n -u) == "$user" ]]; then
        echo "$HOME"
        return
    fi
    getent passwd $user | awk -F: '{ print $6 }'
}

## @fn sys_reset_home_ownership()
## @brief Resets ownership of a user (after ``sys_user_push()``/``sys_user_pop()``)
## @param user account to modify
sys_reset_home_ownership() {
    local home
    local user="${1:-$USER}"

    if [ -z "$user" ]; then
        io_error "sys_reset_home_ownership: user name required"
        false
        return
    fi

    home="$(getent passwd $user | awk -F: '{ print $6 }')"
    if [ -z "$home" ] || (( $(wc -l <<< "$home") > 1 )) ; then
        io_error "sys_reset_home_ownership: reset failed"
        false
        return
    fi

    io_info "sys_reset_home_ownership: ${home} will be owned by ${user}"
    chown -R "${user}": "${home}"
}

## @fn sys_pkg_get_manager()
## @brief Get the system package manager
## @retval result the path to the package manager
sys_pkg_get_manager() {
    local managers=(
        "dnf"
        "yum"
        "apt"
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
case "$sys_manager_cmd" in
    */dnf)
        HAVE_DNF=1
        HAVE_REDHAT=1
        sys_manager_cmd_install="dnf -y install"
        sys_manager_cmd_update="dnf -y update"
        sys_manager_cmd_clean="dnf clean all"
        sys_manager_cmd_list="rpm -qa"
        ;;
    */yum)
        HAVE_YUM=1
        HAVE_REDHAT=1
        sys_manager_cmd_install="yum -y install"
        sys_manager_cmd_update="yum -y update"
        sys_manager_cmd_clean="yum clean all"
        sys_manager_cmd_list="rpm -qa"
        ;;
    */apt)
        HAVE_APT=1
        HAVE_DEBIAN=1
        DEBIAN_FRONTEND=noninteractive
        sys_manager_cmd_install="apt update && apt -y install"
        sys_manager_cmd_update="apt update && apt -y upgrade"
        sys_manager_cmd_clean="apt -y autoremove && apt -y clean"
        sys_manager_cmd_list="apt -qq list"
        ;;
    *)
        io_warn "Unable to determine the system package manager."
        HAVE_SUPPORT=0
        ;;
esac
io_info "system: Detected package manager: $sys_manager_cmd"
io_info "system: is based on Red Hat? $(( HAVE_REDHAT ))"
io_info "system: is based on Debian? $(( HAVE_DEBIAN ))"

## @fn sys_pkg_install()
## @brief Install a system package
## @param ... a variable length list of packages to install
## @retval exit_code of system package manager
##
## @code{.sh}
## # Install vim and nano
## sys_pkg_install nano
## if (( $HAVE_REDHAT )); then
##     sys_pkg_install vim
## elif (( $HAVE_DEBIAN )); then
##     sys_pkg_install vim-common
## fi
##
## # Alternative method using an array to dynamically set dependencies
## deps=(nano)
## (( $HAVE_REDHAT )) && deps+=(vim)
## (( $HAVE_DEBIAN )) && deps+=(vim-common)
## sys_pkg_install "${deps[@]}"

## @endcode
sys_pkg_install() {
    if (( ! HAVE_SUPPORT )); then
        io_error "sys_pkg_install: unsupported package manager"
        return
    fi
    if (( "$#" < 1 )); then
        io_error "sys_pkg_install: at least one package name is required"
        false
        return
    fi
    io_info "sys_pkg_install: Installing $@"
    sh -c "$sys_manager_cmd_install $@"
}

## @fn sys_pkg_update_all()
## @brief Update all system packages
## @retval exit_code of system package manager
sys_pkg_update_all() {
    if (( ! HAVE_SUPPORT )); then
        io_error "sys_pkg_update_all: unsupported package manager"
        return
    fi
    io_info "sys_pkg_update_all: Updating system packages"
    sh -c "$sys_manager_cmd_update"
}

## @fn sys_pkg_installed()
## @brief Test if a system package is installed
## @param name of a system package
## @retval false if package is NOT installed
## @retval true if package is installed
sys_pkg_installed() {
    local output=''
    local name="$1"
    if (( ! HAVE_SUPPORT )); then
        io_error "sys_pkg_installed: unsupported package manager"
        return
    fi

    if (( "$#" < 1 )); then
        io_error "sys_pkg_installed: package name is required"
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
        if grep -E ''^$1/.*\\[installed\\]$'' <<< "$output" &>/dev/null; then
            true
            return
        fi
    fi

    false
    return
}

## @fn sys_pkg_clean()
## @brief Clean the system package manager's cache(s)
sys_pkg_clean() {
    if (( ! HAVE_SUPPORT )); then
        io_error "sys_pkg_clean: unsupported package manager"
        return
    fi
    io_info "sys_pkg_clean: Clearing caches"
    sh -c "$sys_manager_cmd_clean"
}
