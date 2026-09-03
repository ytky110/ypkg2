_list() {
    _version="1,2"
    _color="YES"

    for _arg in "$@"
    do
        case "$_arg" in
        -1)
            if [ "$_version" != 2 ]
            then
                _version=1
            else
                echo "ypkg2: You can't specify -1 option with -2"
                _badusage list
            fi
            ;;
        -2)
            if [ "$_version" != 1 ]
            then
                _version=2
            else
                echo "ypkg2: You can't specify -2 option with -1"
                _badusage list
            fi
            ;;
        -c)
            _color="NO"
            ;;
        -*)
            echo "ypkg2: Unknown option. You can't concatenate options."
            _badusage list
            ;;
        *)
            _badusage list
            ;;
        esac
    done

    if [ "$_version" = 1 ]
    then
        _list_v1 $_color
    elif [ "$_version" = 2 ]
    then
        _list_v2 $_color
    else
        echo "pkgs/	(v1-package)"
        _list_v1 $_color | sed 's/^/    /'
        echo
        echo "pkg2/	(v2-package)"
        _list_v2 $_color | sed 's/^/    /'
    fi

    return 0
}

_list_v1() {
    _color="$1"

    for _pkg in "$prefix_path"/pkgs/*
    do
        if ! [ -d "$_pkg" ]
        then
            echo "No package installed."
            return 0
        fi

        _pkgname=`basename $_pkg`

        if [ -e "$_pkg/.enabled" ]
        then
            [ "$_color" = YES ] \
                && printf "%s\t\033[1m\033[32menabled\033[0m" "$_pkgname" \
                || printf "%s\tenabled" "$_pkgname"
        else
            [ "$_color" = YES ] \
                && printf "%s\t\033[1m\033[31mdisabled\033[0m" "$_pkgname" \
                || printf "%s\tdisabled" "$_pkgname"
        fi
    done | column -t
    return 0
}

_list_v2() {
    _color="$1"

    for _pkg in "$prefix_path"/pkg2/*
    do
        if ! [ -d "$_pkg" ]
        then
            echo "debug: $_pkg"
            [ "$_color" = YES ] \
                && printf "\033[31mNo package installed.\033[0m" \
                || printf "No package installed."
            return 0
        fi

        _pkgname=`basename $_pkg`

        echo "$_pkgname"
        for _pkgv in "$_pkg"/*
        do
            [ -d "$_pkgv" ] || break

            _pkgversion=`basename $_pkgv`

            if [ -e "$_pkgv/.enabled" ]
            then
                [ "$_color" = YES ] \
                    && printf "%s\t\033[1m\033[32menabled\033[0m\n" "$_pkgversion" \
                    || printf "%s\tenabled\n" "$_pkgversion"
            else
                [ "$_color" = YES ] \
                    && printf "%s\t\033[1m\033[31mdisabled\033[0m\n" "$_pkgversion" \
                    || printf "%s\tdisabled\n" "$_pkgversion"
            fi
        done | column -t | sed 's/^/    /'
    done
    return 0
}
