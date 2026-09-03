_install() {
    if [ $# = 0 ]
    then
        _badusage install
    fi

    _force="NO"
    for _path in "$@"
    do
        if [ "$_path" = -f ]
        then
            _force="YES"
            continue
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

        if ! [ -f "$prefix_path/tmp/.pkginfo" ]
        then
            echo "ypkg2: .pkginfo doens't exist in the package or is a directory."
            exit 1
        fi

        if ! . "$prefix_path/tmp/.pkginfo"
        then
            echo "ypkg2: Failed to read .pkginfo"
            echo "ypkg2: It has to be a sh script defining variables"
            exit 1
        fi

        if [ "$pkgversion" = 2 ]
        then
            _install_v2 "$_force"
        else
            _install_v1 "$_force"
        fi
    done

    return 0
}


_install_v1() {
    if [ -d "$prefix_path/pkgs/$name" ]
    then
        echo "ypkg2: The v1-package '$name' already exists"
        exit 1
    fi

    echo "Adding v1-package '$name'..."
    cp -R "$prefix_path/tmp" "$prefix_path/pkgs/$name"
    echo "Successfuly installed $name."

    return 0
}

_install_v2() {
    if [ -d "$prefix_path/pkg2/$name/$version" ]
    then
        echo "ypkg2: The v2-package '$name' version '$version' is already installed."
        exit 1
    fi

    if [ "$1" = YES ]
    then
        echo "ypkg2: Architecture and OS verification skipped."
    else
        _install_check_architecture
    fi

    mkdir -p "$prefix_path/pkg2/$name/"
    echo "Adding v2-package '$name' version '$version'..."
    cp -R "$prefix_path/tmp" "$prefix_path/pkg2/$name/$version"
    echo "Successfuly installed $name/$version."

    return 0
}

_install_check_architecture() {
    if ! [ -z "$arch" -o "$arch" = any ]
    then
        _host_arch=`_get_host_info arch`
        if [ "$arch" != "$_host_arch" ]
        then
            echo "ypkg2: Not for this $_host_arch computer: $arch"
            exit 1
        fi
    fi

    if ! [ -z "$os" -o "$os" = any ]
    then
        _host_os=`_get_host_info os`
        if [ "$os" != "$_host_os" ]
        then
            echo "ypkg2: Not for $_host_os: $os"
            exit 1
        fi
    fi

    return 0
}
