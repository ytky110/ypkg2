#!/bin/sh

version="0.1.1"
config_file="$HOME/.config/ypkg.conf"
prefix_path="$HOME/.ypkg2.d"

main() {
    if ! command -v stow >/dev/null 2>&1
    then
        echo "ypkg2: stow command is not available."
        echo "ypkg2: ypkg2 needs that stow is available in PATH."
        exit 1
    fi

    if [ $# = 0 ]
    then
        _badusage
    fi

    _loadconfig
    if ! [ -d $prefix_path ]
    then
        echo "ypkg2: The prefix path '$prefix_path' doesn't exist."
        echo "ypkg2: Check the config file '$config_file'"
        exit 1
    fi
    _makedirs
    _cleartmp

    op="$1"
    shift
    case "$op" in
    install)
        _install "$@"
        ;;
    remove)
        _remove "$@"
        ;;
    enable)
        _enable "$@"
        ;;
    disable)
        _disable "$@"
        ;;
    switch)
        _switch "$@"
        ;;
    list)
        _list "$@"
        ;;
    getprefix)
        _getprefix "$@"
        ;;
    help|-h|--help)
        for i in general install enable disable list getprefix help version
        do
            _usage "$i"
        done
        ;;
    version|-v|--version)
        echo $version
        ;;
    *)
        echo "ypkg2: $op: Unknown operation."
        _badusage
        ;;
    esac
    exit 0
}
