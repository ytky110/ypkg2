# ypkg2

My original package format and manager.

ypkg2 is a package management system for my programs, to install in home.

- [Prefix](#prefix)
- [Package](#package)
- [Usage](#usage)

## Prefix

All ypkg2's packages are installed under the prefix.

The defualt prefix is `~/.ypkg2.d`.

If the configuration file at `~/.config/ypkg2.conf` exists,
ypkg2 will read that and use as filename.
(Write just the filename, it is just a `cat` command).

The structure of the prefix is this.

```
~/.ypkg2.d/
├── cache/
├── local/
│   ├── bin/
│   ├── etc/
│   ├── include/
│   ├── lib/
│   ├── share/
│   └── var/
├── pkg2/
├── pkgs/
└── tmp/
```

`cache/` is where packages are copied to install them.
You can erase its content no problem.

`local/` is like `/usr` or `/usr/local`.
It's content packages' files to use.
I designed to use like `/usr/local`,
but I think just `bin/` is enough for most packages.

`pkg2/` is where packages are installed.
Packages are grouped by name and contains each versions like this:

```
pkg2/
├── foo/
│   ├── 1.0/
│   └── 1.1/
└── bar/
    └── 2.0/
```

`pkgs/` is where packages of ypkg are installed.
ypkg is the package manager I made before,
and I let compatibility in ypkg2 with these packages.
But I didn't publish this, so I won't write the document for this.

`tmp/` is where packages are extracted to install. Emptied each time.

## Package

A ypkg2 package has a directory structure like the `local/`

```
./
├── bin/
├── etc/
├── include/
├── lib/
├── share/
├── var/
└── .pkginfo
```

The directories' contents are symlinked with stow when you enable the package.

.pkginfo is the essential file for the package.
It stores these package information as sh script:
`pkgversion`, `name`, `version`, `arch` and `os`.

`pkgversion` is used to distinguish if
it's a ypkg2 package and not a ypkg package.
It always "2" for ypkg2 package.

`name` is the name of the package, `version` the version.
It can't contain character not allowed in filenames.

`arch` is the target architecture.

```
x86_64        x86_64|amd64
i386          i?86
aarch64       aarch64|arm64
armv7l        armv7l|armv7
```

`os` is the target os.

```
linux         Linux
freebsd       FreeBSD
macos         Darwin
```

`arch` and `os` are checked by ypkg2 with `uname -m` and `-s`.
If it's unknown or unset, ypkg2 aborts,
and if the package is for all arch or os (e.g. it's a shellscript)
it should be written as `any`.

Example of a .pkginfo

```bash
pkgversion=2
name=foo
version=1.0
arch=x86_64
os=linux
```

## Usage

```
$ ypkg2 --help
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

`install` command installs the specified package.
It copies it into `cache/` and extracts to `pkg2/<name>/<version>`.

`enable` makes symlinks of package files to `local/` with stow.
You need to specify like `<name>/<version>`, like `foo/1.0`.

`disable` removes symlinks in `local/`.

`switch` disables the first specified package, and enables the second.
You can use it to upgrade package.

```
ypkg2 switch foo/1.0 foo/1.2
```

`list` lists installed packages.
`-1|-2` options specify to print only ypkg package or ypkg2 package.
`-c` disables color, and with `-n` it will print only name, nothing else.

`getprefix` print the path of prefix.

You can use `--help` or `--version` instead of `help`, `version`.

---

Also see [yports](https://github.com/ytky110/yports),
the ports tree with all ypkg2 packages to build.
