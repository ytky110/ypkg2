_enable() {
    if [ $# = 0 ]
    then
        echo "ypkg2: No package specified."
        _badusage enable
    fi

    for pkg in "$@"
    do
        if [ -d "$prefix_path/pkgs/$pkg" ] -o 
        then
            _pkgdir="$prefix_path/pkgs"
        elif [ -d "$prefix_path/pkg2/$pkg" ]
        then
            _pkgdir="$prefix_path/pkg2"
        else
            echo "ypkg2: Package $pkg is not installed."
            echo "ypkg2: If it's a v2-package, you need to specify like foo/1.2"
            exit 1
        fi

        echo "Enabling $pkg package..."
        if ! stow -v --ignore='.pkginfo' -d "$_pkgdir" -t "$prefix_path/local" "$pkg"
        then
            echo "ypkg2: Failed to enable $pkg package."
            echo "ypkg2: debug: stow -v --ignore='.pkginfo' -d \"$prefix_path/pkgs\" -t \"$prefix_path/local\" \"$pkg\""
            exit 1
        fi

        touch "$_pkgdir/$pkg/.enabled"
        echo "Successfully enabled $pkg."
    done

    return 0
}
