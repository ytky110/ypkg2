_enable() {
    if [ $# = 0 ]
    then
        echo "ypkg2: No package specified."
        _badusage enable
    fi

    for _pkg in "$@"
    do
        if [ -d "$prefix_path/pkgs/$_pkg" ]
        then
            _pkgversion=1
            _pkgdir="$prefix_path/pkgs"
        elif [ -d "$prefix_path/pkg2/$_pkg" ]
        then
            _pkgversion=2
            _pkgdir="$prefix_path/pkg2"
        else
            echo "ypkg2: Package $_pkg is not installed."
            echo "ypkg2: If it's a v2-package, you need to specify like foo/1.2"
            exit 1
        fi

        if [ $_pkgversion = 2 ]
        then
            _name=`dirname "$_pkg"`
            _version=`basename "$_pkg"`

            echo "Enabling $_name version $_version"
            if ! stow -v --ignore='.pkginfo' -d "$_pkgdir/$_name" -t "$prefix_path/local" "$_version"
            then
                echo "ypkg2: Failed to enable $_name version $_version"
                echo "ypkg2: debug: stow -v --ignore='.pkginfo' -d \"$_pkgdir/$_name\" -t \"$prefix_path/local\" \"$_version\""
                exit 1
            fi
        else
            echo "Enabling $_pkg v1-package..."
            if ! stow -v --ignore='.pkginfo' -d "$_pkgdir" -t "$prefix_path/local" "$_pkg"
            then
                echo "ypkg2: Failed to enable $pkg package."
                echo "ypkg2: debug: stow -v --ignore='.pkginfo' -d \"$prefix_path/pkgs\" -t \"$prefix_path/local\" \"$_pkg\""
                exit 1
            fi
        fi

        touch "$_pkgdir/$_pkg/.enabled"
        echo "Successfully enabled $_pkg."
    done

    return 0
}
