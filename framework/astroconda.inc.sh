## @file
## @brief Astroconda control functions

(( $EC2PINIT_ASTROCONDA_INCLUDED )) && return
EC2PINIT_ASTROCONDA_INCLUDED=1
source $ec2pinit_root/config.sh

## @fn ac_platform()
## @brief Get astroconda platform string
## @details The value returned is the platform suffix of a pipeline release
## file name.
## @retval platform if supported platform is detected
## @retval "unknown" if platform is not supported
ac_platform() {
    case $(sys_platform) in
        Linux)
            echo linux ;;
        Win*)
            echo windows ;;
        Darwin)
            echo macos ;;
        *)
            echo unknown ;;
    esac
}


## @fn ac_releases_clone()
## @brief Clone the astroconda-releases repository
## @details The destination is $ec2pinit_tempdir
## @see config.sh
ac_releases_clone() {
    mkdir -p "$ec2pinit_tempdir"
    if [ ! -d "$ac_releases_path" ]; then
        git clone $ac_releases_repo $ac_releases_path >&2
    fi
}


## @fn ac_releases_pipeline_exists()
## @brief Check if a named pipeline exists in astroconda-releases
## @retval path if pipeline exists
## @retval "" if pipeline does not exist
ac_releases_pipeline_exists() {
    local pattern="$1"

    ac_releases_clone
    find $ac_releases_path -maxdepth 1 -type d -name ''$pattern''
}


## @fn ac_releases_pipeline_release_exists()
## @brief Check if a named release exists in a astroconda-releases pipeline
## @param pipeline_name Pipeline name
## @param pipeline_release Pipeline release name
## @retval path if release exists
## @retval "" if release does not exist
ac_releases_pipeline_release_exists() {
    local pipeline_name="$1"
    local pipeline_release="$2"
    result=$(find "$(ac_releases_pipeline_exists $pipeline_name)" -maxdepth 1 -name ''$pipeline_release'')
    if [ -n "$result" ]; then
        readlink -f $result
    fi
}


## @fn ac_releases_data_analysis()
## @brief Get path to data analysis release file
## @param series Pipeline release name
## @retval latest_path if series is undefined
## @retval path if series is found
ac_releases_data_analysis() {
    local series="$1"
    local pipeline="de"
    if [ -z "$series" ]; then
        # get implicit latest in the release series
        release=$(find "$(ac_releases_pipeline_exists $pipeline)" \
                    -name ''latest-$(ac_platform)*.yml'' \
                    | sort -V | tail -n 1)
    else
        # get the latest release for the requested series
        release=$(find "$(ac_releases_pipeline_exists $pipeline)" \
                    -wholename ''\*$series/latest-$(ac_platform).yml'' \
                    | sort -V | tail -n 1)
    fi
    if [ -n "$release" ]; then
        readlink -f "$release"
    fi
}


## @fn ac_releases_data_analysis_environ()
## @brief Generate conda environment name
## @param series Pipeline release name
## @retval environment_name if series exists
## @retval false if release cannot be found
ac_releases_data_analysis_environ() {
    local series="$1"
    local filename=$(ac_releases_data_analysis "$series")
    if [ -z "$filename" ]; then
        false
        return
    fi
    sed "s/-/_/g;s/_$(ac_platform).*//g" <<< $(basename $filename)
}


## @fn ac_releases_jwst()
## @brief Get path to JWST pipeline release file(s)
## @details JWST splits its installation into two files. This function returns
## two strings separated by new lines.
## @param series Pipeline release name
## @retval latest_path if series is undefined
## @retval paths if series is found
ac_releases_jwst() {
    local series="$1"
    local pipeline="jwstdp"
    if [ -z "$series" ]; then
        # get implicit latest in the release series
        release=$(find "$(ac_releases_pipeline_exists $pipeline)" \
                    -name ''*.txt'' -and \( -not -name ''*macos*'' \) \
                    | sort -V | tail -n 2)
    else
        # get the latest release for the requested series
        release=$(find "$(ac_releases_pipeline_exists $pipeline)" \
                    -wholename ''\*$series/*.txt'' -and \( -not -wholename ''\*$series/\*macos\*.txt'' \) \
                    | sort -V | tail -n 2)
    fi
    echo "$release"
}


## @fn ac_releases_jwst_environ()
## @brief Generate conda environment name
## @param series Pipeline release name
## @retval environment_name if series exists
## @retval false if release cannot be found
ac_releases_jwst_environ() {
    local series="$1"
    local pipeline="jwstdp"
    if [ -z "$series" ]; then
        # get implicit latest in the release series
        release=$(find "$(ac_releases_pipeline_exists $pipeline)" \
                    -maxdepth 1 \
                    -type d \
                    -not -wholename ''*/utils*'' \
                    | sort -V | tail -n 1)
    else
        # get the latest release for the requested series
        release=$(find "$(ac_releases_pipeline_exists $pipeline)" \
                    -type d \
                    -wholename ''\*/$series'' \
                    | sort -V | tail -n 1)
    fi
    printf "JWSTDP_%s" $(basename $release)
}


## @fn ac_releases_hst()
## @brief Get path to HST pipeline release file
## @details HST provides a platform dependent YAML configuration
## @param series Pipeline release name
## @retval latest_path if series is undefined
## @retval path if series is found
ac_releases_hst() {
    local series="$1"
    local pipeline="caldp"  # no one will ever use hstdp
    if [ -z "$series" ]; then
        # get implicit latest in the release series
        release=$(find "$(ac_releases_pipeline_exists $pipeline)" \
                    -name ''latest-$(ac_platform)*.yml'' \
                    | sort -V | tail -n 1)
    else
        # get the latest release for the requested series
        release=$(find -L "$(ac_releases_pipeline_exists $pipeline)" \
                    -wholename ''\*$series/latest-$(ac_platform).yml'' \
                    | sort -V | tail -n 1)
    fi
    if [ -n "$release" ]; then
        readlink -f "$release"
    fi
}


## @fn ac_releases_hst_environ()
## @brief Generate conda environment name
## @param series Pipeline release name
## @retval environment_name if series exists
## @retval false if release cannot be found
ac_releases_hst_environ() {
    local series="$1"
    local filename=$(ac_releases_hst "$series")
    if [ -z "$filename" ]; then
        false
        return
    fi
    sed "s/_$(ac_platform).*//" <<< $(basename $filename)
}


## @fn ac_releases_install_hst()
## @brief Install the HST pipeline
## @param version 
ac_releases_install_hst() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "ac_releases_install_hst: release version required" >&2
        false
        return
    fi
    local release_file=$(ac_releases_hst $version)
    local release_name=$(ac_releases_hst_environ $version)
    conda env create -n $release_name --file $release_file
}


## @fn ac_releases_install_jwst()
## @brief Install the JWST pipeline
## @param version 
ac_releases_install_jwst() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "ac_releases_install_jwst: release version required" >&2
        false
        return
    fi
    release_file=($(ac_releases_jwst $version_jwst))
    release_name=$(ac_releases_jwst_environ $version_jwst)
    conda create -n $release_name --file ${release_file[0]}
    conda activate $release_name
    python -m pip install -r ${release_file[1]}
    conda deactivate
}


## @fn ac_releases_install_data_analysis()
## @brief Install the data analysis pipeline
## @param version 
ac_releases_install_data_analysis() {
    local version="$1"
    if [ -z "$version" ]; then
        echo "ac_releases_install_data_analysis: release version required" >&2
        false
        return
    fi
    local release_file=$(ac_releases_data_analysis $version)
    local release_name=$(ac_releases_data_analysis_environ $version)
    conda env create -n $release_name --file $release_file
}
