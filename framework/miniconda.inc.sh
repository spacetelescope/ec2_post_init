(( $EC2PINIT_MINICONDA_INCLUDED )) && return
EC2PINIT_MINICONDA_INCLUDED=1
source $ec2pinit_root/ec2pinit.inc.sh

# Miniconda control functions

## @fn mc_get()
## @brief Download Miniconda3
## @details Installation script destination is set by global $mc_installer
## @param version Miniconda3 release version...
##   (i.e., py39_4.11.0)
## @see config.sh
mc_get() {
    local version="$1"
    local platform="$(sys_platform)"
    local arch="$(sys_arch)"
    local name="Miniconda3-$version-$platform-$arch.sh"

    if [ -f "$mc_installer" ]; then
        return
    fi

    curl -L -o $mc_installer "$mc_url/$name"
}


## @fn mc_configure_defaults()
## @brief Sets global defaults for conda and pip
mc_configure_defaults() {
    if [ -z "$CONDA_EXE" ]; then
        # Not initialized correctly
        false
        return
    fi
    conda config --system --set auto_update_conda false
    conda config --system --set always_yes true
    conda config --system --set report_errors false
    if ! grep -E '[^#](export)?[\t\ ]+PIP_VERBOSE=' ~/.bash_profile &>/dev/null; then
        echo export PIP_VERBOSE=1 >> $HOME/.bash_profile
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
    local cmd="bash $mc_installer -b -p $dest"

    if [ -z "$version" ]; then
        echo "mc_install: miniconda version required" >&2
        return false
    fi

    if [ -z "$dest" ]; then
        echo "mc_install: miniconda destination directory required" >&2
        false
        return
    elif [ -d "$dest" ]; then
        echo "mc_install: miniconda destination directory exists" >&2
        false
        return
    fi

    if ! mc_get "$version"; then
        echo "mc_install: unable to obtain miniconda from server" >&2
        false
        return
    fi

    $cmd
}


## @fn mc_clean()
## @brief Remove unused tarballs, caches, indexes, etc
## @retval false if miniconda is not initialized
mc_clean() {
    if [ -z "$CONDA_EXE" ]; then
        # Not initialized correctly
        false
        return
    fi

    conda clean --all
}

