_disable() {
    if [ $# = 0 ]
    then
        echo "ypkg2: No package specified."
        _badusage disable
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

            # when 'ypkg2 enable foo', foo is stored in _version and _name is '.'
            if [ "$_name" = . ]
            then
                echo "ypkg2: Please specify version."
                echo "ypkg2: You need to specify like foo/1.2"
                exit 1
            fi

            if [ ! -e "$_pkgdir/$_name/$_version/.enabled" ]
            then
                echo "ypkg2: The v2-package $_name version $_version is not enabled."
                echo "ypkg2: Please run 'ypkg2 enable $_name/$_version' to enable it."
                exit 1
            fi

            echo "Disabling v2-package $_name version $_version..."
            if ! stow -D -v -d "$_pkgdir/$_name" -t "$prefix_path/local" "$_version"
            then
                echo "ypkg2: Failed to disable $_name version $_version"
                echo "ypkg2: debug: stow -D -v -d \"$_pkgdir/$_name\" -t \"$prefix_path/local\" \"$_version\""
                exit 1
            fi
        else
            if [ ! -e "$_pkgdir/$_pkg/.enabled" ]
            then
                echo "ypkg2: The v1-package $_pkg is not enabled."
                echo "ypkg2: Please run 'ypkg2 enable $_name/$_version' to enable it."
                exit 1
            fi

            echo "Disabling $_pkg v1-package..."
            if ! stow -D -v -d "$_pkgdir" -t "$prefix_path/local" "$_pkg"
            then
                echo "ypkg2: Failed to enable $pkg package."
                echo "ypkg2: debug: stow -D -v -d \"$prefix_path/pkgs\" -t \"$prefix_path/local\" \"$_pkg\""
                exit 1
            fi
        fi

        rm "$_pkgdir/$_pkg/.enabled"
        echo "Successfully disabled $_pkg."
    done
}
