# ypkg2

My original package format and manager.

I didn't write so much document, and I haven't considered other people using it yet..

It's use GNU stow.

```
$ bin/ypkg2 help
usage: ypkg2 {OPERATION} <TARGET>...
usage: ypkg2 install [-f] <TARGET>...
usage: ypkg2 enable <TARGET>...
usage: ypkg2 disable <TARGET>...
usage: ypkg2 switch <FROM> <TO>
usage: ypkg2 list [-1 | -2] [-c] [-n]
usage: ypkg2 getprefix
usage: ypkg2 help
usage: ypkg2 version
```

Also see [yports](https://github.com/ytky110/yports), the ports tree with all ypkg2 packages to build.
