_install() {
    if [ $# = 0 ]
    then
        echo "ypkg2: No package specified."
        _badusage install
    fi

    _force="NO"
    for _path in "$@"
    do
        if [ "$_path" = -f ]
        then
            _force="YES"
        fi

        _filename=`basename $_path`

        echo "Copying to cache/"
        cp "$_path" "$prefix_path/cache" || exit 1
        echo "Extracting to tmp/"
        if ! tar -x --zstd -f "$prefix_path/cache/$_filename" -C "$prefix_path/tmp"
        then
            echo "ypkg: Failed to extract package."
            echo "ypkg: It has to be a .tar.zst (.tzst) file"
            rm "$prefix_path/cache/$_filename"
            exit 1
        fi

        _pkgversion=`_getparam VERSION "$prefix_path/tmp"`
        if [ "$_pkgversion" = 2 ]
        then
            _install_v2 "$_force"
        else
            _install_v1
        fi
    done

    return 0
}


_install_v1() {
    _name=`_getparam name "$prefix_path/tmp"`

    if [ -d "$prefix_path/pkgs/$_name" ]
    then
        echo "ypkg2: The v1-package '$_name' already exists"
        exit 1
    fi

    echo "Adding v1-package '$_name'..."
    cp -R "$prefix_path/tmp" "$prefix_path/pkgs/$_name"
    echo "Successfuly installed $_name."

    return 0
}

_install_v2() {
    _name=`_getparam name "$prefix_path/tmp"`
    _version=`_getparam version "$prefix_path/tmp"`
    _arch=`_getparam arch "$prefix_path/tmp"`
    _os=`_getparam os "$prefix_path/tmp"`

    if [ -d "$prefix_path/pkg2/$_name/$_version" ]
    then
        echo "ypkg2: The v2-package '$_name' of version '$_version' is already installed."
        exit 1
    fi

    if [ "$1" = YES ]
    then
        echo "ypkg2: Architecture and OS verification skipped."
    else
        _install_check_architecture "$_arch" "$_os"
    fi

    mkdir -p "$prefix_path/pkg2/$_name/"
    cp -R "$prefix_path/tmp" "$prefix_path/pkg2/$_name/$_version"

    return 0
}

_install_check_architecture() {
    _arch="$1"
    _os="$2"

    if ! [ -z "$_arch" -o "$_arch" = any ]
    then
        _host_arch=`_get_host_info arch`
        if [ "$_arch" != "$_host_arch" ]
        then
            echo "ypkg2: Not for this $_host_arch computer: $_arch"
            exit 1
        fi
    fi

    if ! [ -z "$_os" -o "$_os" = any ]
    then
        _host_os=`_get_host_info os`
        if [ "$_os" != "$_host_os" ]
        then
            echo "ypkg2: Not for $_host_os: $os"
            exit 1
        fi
    fi

    return 0
}
