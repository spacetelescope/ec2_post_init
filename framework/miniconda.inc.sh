## @file
## @brief Miniconda control functions

(( $EC2PINIT_MINICONDA_INCLUDED )) && return
EC2PINIT_MINICONDA_INCLUDED=1
source ec2pinit.inc.sh

# URL to a site providing miniconda installers
mc_url="https://repo.anaconda.com/miniconda"

# Name of miniconda installation script
mc_installer="miniconda3_install.sh"


## @fn _get_rc()
## @private
## @brief Get the default bash rc script for the user account
## @code{.sh}
## # Red Hat...
## rc=$(_get_rc)
## # rc=/home/example/.bash_profile
##
## Debian...
## rc=$(_get_rc)
## # rc=/home/example/.bashrc
## @endcode
## @retval false if ``home`` does not exist
_get_rc() {
    local scripts=(.bash_profile .bashrc .profile)
    local home="$(sys_user_home ${1:-$USER})"
    if [ -z "$home" ] || [ ! -d "$home" ]; then
	false
        return
    fi

    for x in "${scripts[@]}"; do
        local filename="$home/$x"
        [ ! -f "$filename" ] && continue
        echo $filename
        break
    done
}


## @fn mc_get()
## @brief Download Miniconda3
## @details Installation script destination is set by global $mc_installer
## @param version Miniconda3 release version...
##   (i.e., py39_4.11.0)
## @see config.sh
mc_get() {
    local version="$1"
    local dest="$ec2pinit_tempdir"
    local platform="$(sys_platform)"
    local arch="$(sys_arch)"
    local name="Miniconda3-$version-$platform-$arch.sh"

    if [ -f "$dest/$mc_installer" ]; then
	io_warn "mc_get: $dest/$mc_installer exists"
        false
        return
    fi
    io_info "mc_get: Downloading $mc_url/$name"
    io_info "mc_get: Destination: $dest/$mc_installer"
    curl -L -o "$dest/$mc_installer" "$mc_url/$name"
}


## @fn mc_configure_defaults()
## @brief Sets global defaults for conda and pip
mc_configure_defaults() {
    if [ -z "$CONDA_EXE" ]; then
        # Not initialized correctly
	io_error "mc_configure_defaults: conda is not initialized"
        false
        return
    fi
    io_info "mc_configure_defaults: Configuring conda options"
    conda config --system --set auto_update_conda false
    conda config --system --set always_yes true
    conda config --system --set report_errors false

    # Some skeletons default to .bashrc instead of .bash_profile.
    local rc="$(_get_rc)"
    io_info "mc_configure_defaults: Enabling verbose output from pip"
    if ! grep -E '[^#](export)?[\t\ ]+PIP_VERBOSE=' "$rc" &>/dev/null; then
        echo export PIP_VERBOSE=1 >> "$rc"
	io_info "mc_configure_defaults: $rc modified"
    else
	io_info "mc_configure_defaults: $rc not modified"
    fi
}


## @fn mc_initialize()
## @brief Configures user account to load conda at login
## @param dest path to miniconda installation root
mc_initialize() {
    local dest="$1"
    if [[ $- =~ v ]]; then
        set +v
        trap 'set -v' RETURN
    fi
    if [[ $- =~ x ]]; then
        set +v
        trap 'set -x' RETURN
    fi

    io_info "mc_initialize: Using conda: $dest"
    source "$dest"/etc/profile.d/conda.sh ; conda init
    mc_configure_defaults
}


## @fn mc_install()
## @brief Installs Miniconda3
## @param version of the Miniconda3 installer (i.e., py39_4.11.0)
## @param dest path to install Miniconda3 (~/miniconda3)
## @retval false if any argument is invalid
## @retval false if destination exists
## @retval false if download fails
## @retval false if installation fails (implicit)
mc_install() {
    local version="$1"
    local dest="$2"
    local cmd="bash "$ec2pinit_tempdir/$mc_installer" -b -p $dest"
    
    if [ -z "$version" ]; then
        io_error "mc_install: miniconda version required" >&2
        return false
    fi

    if [ -z "$dest" ]; then
        io_error "mc_install: miniconda destination directory required" >&2
        false
        return
    elif [ -d "$dest" ]; then
        io_error "mc_install: miniconda destination directory exists" >&2
        false
        return
    fi

    if mc_get "$version"; then
        io_error "mc_install: unable to obtain miniconda from server" >&2
        false
        return
    fi

    io_info "mc_install: Installing conda: $dest"
    $cmd
}


## @fn mc_clean()
## @brief Remove unused tarballs, caches, indexes, etc
## @retval false if miniconda is not initialized
mc_clean() {
    if [ -z "$CONDA_EXE" ]; then
        # Not initialized correctly
	io_error "mc_clean: conda is not initialized"
        false
        return
    fi

    conda clean --all
}

