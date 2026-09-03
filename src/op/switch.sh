_switch() {
    if [ $# -lt 2 ]
    then
        _badusage switch
    fi

    _disable "$1"
    _enable "$2"

    echo "Successfully switched from $1 to $2"
    return 0
}
