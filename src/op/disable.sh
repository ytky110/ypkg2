_disable() {
    if [ $# = 0 ]
    then
        echo "ypkg2: No package specified."
        _badusage disable
    fi

    for _pkg in "$@"
    do
        _set_pkgdir_pkgversion "$_pkg"

        if [ $pkgversion = 2 ]
        then
            _get_name_version_pkg2 "$_pkg"
            _should_be_enabled_pkg2

            echo "Disabling v2-package $name version $version..."
            if ! stow -D -v -d "$pkgdir/$name" -t "$prefix_path/local" "$version"
            then
                echo "ypkg2: Failed to disable $name version $version"
                echo "ypkg2: debug: stow -D -v -d \"$pkgdir/$name\" -t \"$prefix_path/local\" \"$version\""
                exit 1
            fi
        else
            _should_be_enabled_pkg1 "$_pkg"

            echo "Disabling $_pkg v1-package..."
            if ! stow -D -v -d "$pkgdir" -t "$prefix_path/local" "$_pkg"
            then
                echo "ypkg2: Failed to enable $pkg package."
                echo "ypkg2: debug: stow -D -v -d \"$prefix_path/pkgs\" -t \"$prefix_path/local\" \"$_pkg\""
                exit 1
            fi
        fi

        rm "$pkgdir/$_pkg/.enabled"
        echo "Successfully disabled $_pkg."
    done
}
