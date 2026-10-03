_usage() {
    if [ $# -gt 0 ]
    then
        op="$1"
    fi

    case "$op" in
    install)
        echo "usage: ypkg2 install [-f] <TARGET>..."
        ;;
    remove)
        echo "usage: ypkg2 remove <TARGET>..."
        ;;
    enable)
        echo "usage: ypkg2 enable <TARGET>..."
        ;;
    disable)
        echo "usage: ypkg2 disable <TARGET>..."
        ;;
    switch)
        echo "usage: ypkg2 switch <FROM> <TO>"
        ;;
    list)
        echo "usage: ypkg2 list [-1 | -2] [-c] [-n]"
        ;;
    getprefix)
        echo "usage: ypkg2 getprefix"
        ;;
    help)
        echo "usage: ypkg2 help"
        ;;
    version)
        echo "usage: ypkg2 version"
        ;;
    *)
        echo "usage: ypkg2 {OPERATION} <TARGET>..."
        ;;
    esac

    return 0
}

_badusage() {
    echo `_usage "$1"`
    echo "Use 'ypkg2 --help' for more information."
    exit 2
}

_loadconfig() {
    if [ -f $config_file ]
    then
        prefix_path=`cat $config_file`
    fi

    return 0
}

_makedirs() {
    for dir in cache local/bin local/etc local/include \
               local/lib local/share local/var pkgs pkg2 tmp
    do
        if ! [ -d $prefix_path/$dir ]
        then
            mkdir -p $prefix_path/$dir
        fi
    done

    return 0
}

_cleartmp() {
    rm -rf "$prefix_path/tmp"
    mkdir "$prefix_path/tmp" || echo "ypkg2: error making tmp"
    return 0
}

_get_host_info() {
    case "$1" in
    arch)
        _raw_arch=`uname -m`
        case "$_raw_arch" in
            x86_64|amd64)
                echo x86_64
                ;;
            i?86)
                echo i386
                ;;
            aarch64|arm64)
                echo aarch64
                ;;
            armv7l|armv7)
                echo armv7l
                ;;
            *)
                echo "$_raw_arch"
                ;;
        esac
        ;;
    os)
        _raw_os=`uname -s`
        case "$_raw_os" in
            Linux)
                echo linux
                ;;
            FreeBSD)
                echo freebsd
                ;;
            Darwin)
                echo macos
                ;;
            *)
                echo unknown
                ;;
        esac
        ;;
    esac

    return 0
}

_set_pkgdir_pkgversion() {
    if [ -d "$prefix_path/pkgs/$1" ]
    then
        pkgversion=1
        pkgdir="$prefix_path/pkgs"
    elif [ -d "$prefix_path/pkg2/$1" ]
    then
        pkgversion=2
        pkgdir="$prefix_path/pkg2"
    else
        echo "ypkg2: Package $1 is not installed."
        echo "ypkg2: If it's a v2-package, you need to specify like foo/1.2"
        exit 1
    fi
}

_get_name_version_pkg2() {
    name=`dirname "$1"`
    version=`basename "$1"`

    # when 'ypkg2 enable foo', foo is stored in _version and _name is '.'
    if [ "$_name" = . ]
    then
        echo "ypkg2: Please specify version."
        echo "ypkg2: You need to specify like foo/1.2"
        exit 1
    fi
}

_should_be_enabled_pkg1() {
    if [ ! -e "$pkgdir/$1/.enabled" ]
    then
        echo "ypkg2: The v1-package $1 is not enabled."
        echo "ypkg2: Please run 'ypkg2 enable $1' to enable it."
        exit 1
    fi
}

_should_be_disabled_pkg1() {
    if [ -e "$pkgdir/$1/.enabled" ]
    then
        echo "ypkg2: The v1-package $1 is already enabled."
        echo "ypkg2: Please run 'ypkg2 disable $1' to disable it."
        exit 1
    fi
}

_should_be_enabled_pkg2() {
    if [ ! -e "$pkgdir/$name/$version/.enabled" ]
    then
        echo "ypkg2: The v2-package $name version $version is not enabled."
        echo "ypkg2: Please run 'ypkg2 enable $name/$version' to enable it."
        exit 1
    fi
}

_should_be_disabled_pkg2() {
    if [ -e "$pkgdir/$name/$version/.enabled" ]
    then
        echo "ypkg2: The v2-package $name version $version is already enabled."
        echo "ypkg2: Please run 'ypkg2 disable $name/$version' to disable it."
        exit 1
    fi
}

