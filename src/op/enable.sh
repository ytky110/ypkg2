_enable() {
    if [ $# = 0 ]
    then
        echo "ypkg2: No package specified."
        _badusage enable
    fi

    for _pkg in "$@"
    do
        _set_pkgdir_pkgversion "$_pkg"


        if [ $pkgversion = 2 ]
        then
            _get_name_version_pkg2 "$_pkg"
            _should_be_disabled_pkg2

            echo "Enabling v2-package $name version $version..."
            if ! stow -v --ignore='.pkginfo' -d "$pkgdir/$name" -t "$prefix_path/local" "$version"
            then
                echo "ypkg2: Failed to enable $name version $version"
                echo "ypkg2: debug: stow -v --ignore='.pkginfo' -d \"$pkgdir/$name\" -t \"$prefix_path/local\" \"$version\""
                exit 1
            fi
        else
            _should_be_disabled_pkg1 "$_pkg"

            echo "Enabling $_pkg v1-package..."
            if ! stow -v --ignore='.pkginfo' -d "$pkgdir" -t "$prefix_path/local" "$_pkg"
            then
                echo "ypkg2: Failed to enable $pkg package."
                echo "ypkg2: debug: stow -v --ignore='.pkginfo' -d \"$prefix_path/pkgs\" -t \"$prefix_path/local\" \"$_pkg\""
                exit 1
            fi
        fi

        touch "$pkgdir/$_pkg/.enabled"
        echo "Successfully enabled $_pkg."
    done

    return 0
}
