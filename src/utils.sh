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
        echo "usage: ypkg2 switch <FROM> <TO>..."
        ;;
    list)
        echo "usage: ypkg2 list"
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
    echo `_usage "$op"`
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
               local/lib local/shrae local/var pkgs pkg2 tmp
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
