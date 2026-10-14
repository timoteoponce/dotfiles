# Homebrew's brew script throws away PATH and keeps only
# /usr/bin:/bin:/usr/sbin:/sbin. The installer also calls a few
# programs by absolute path. NixOS ships those tools, but not at
# those paths, so the SSSE3 check dies with "grep: command not found".
{ pkgs, lib, ... }:
let
  link = path: target: "L+ ${path} - - - - ${target}";
  linkBins =
    dir: pkg: names:
    map (name: link "${dir}/${name}" "${pkg}/bin/${name}") names;

  coreutils = pkgs.coreutils-full;
  # Every name in coreutils-full's bin. "[" is a real program.
  coreutilsBins = [
    "["
    "b2sum"
    "base32"
    "base64"
    "basename"
    "basenc"
    "cat"
    "chcon"
    "chgrp"
    "chmod"
    "chown"
    "chroot"
    "cksum"
    "comm"
    "cp"
    "csplit"
    "cut"
    "date"
    "dd"
    "df"
    "dir"
    "dircolors"
    "dirname"
    "du"
    "echo"
    "expand"
    "expr"
    "factor"
    "false"
    "fmt"
    "fold"
    "groups"
    "head"
    "hostid"
    "id"
    "install"
    "join"
    "kill"
    "link"
    "ln"
    "logname"
    "ls"
    "md5sum"
    "mkdir"
    "mkfifo"
    "mknod"
    "mktemp"
    "mv"
    "nice"
    "nl"
    "nohup"
    "nproc"
    "numfmt"
    "od"
    "paste"
    "pathchk"
    "pinky"
    "pr"
    "printenv"
    "printf"
    "ptx"
    "pwd"
    "readlink"
    "realpath"
    "rm"
    "rmdir"
    "runcon"
    "seq"
    "sha1sum"
    "sha224sum"
    "sha256sum"
    "sha384sum"
    "sha512sum"
    "shred"
    "shuf"
    "sleep"
    "sort"
    "split"
    "stat"
    "stdbuf"
    "stty"
    "sum"
    "sync"
    "tac"
    "tail"
    "tee"
    "test"
    "timeout"
    "touch"
    "tr"
    "true"
    "truncate"
    "tsort"
    "tty"
    "uname"
    "unexpand"
    "uniq"
    "unlink"
    "uptime"
    "users"
    "vdir"
    "wc"
    "who"
    "whoami"
    "yes"
  ];
in
{
  systemd.tmpfiles.rules =
    [
      (link "/bin/bash" "${pkgs.bashInteractive}/bin/bash")
      (link "/usr/bin/sudo" "/run/wrappers/bin/sudo")
    ]
    # Installer calls these under /bin, not /usr/bin.
    ++ linkBins "/bin" coreutils [
      "chown"
      "chgrp"
      "chmod"
      "mkdir"
      "touch"
      "stty"
    ]
    ++ linkBins "/usr/bin" coreutils coreutilsBins
    ++ linkBins "/usr/bin" pkgs.gnugrep [
      "grep"
      "egrep"
      "fgrep"
    ]
    ++ linkBins "/usr/bin" pkgs.gnused [ "sed" ]
    ++ linkBins "/usr/bin" pkgs.gawk [
      "awk"
      "gawk"
    ]
    ++ linkBins "/usr/bin" pkgs.git [ "git" ]
    ++ linkBins "/usr/bin" (lib.getBin pkgs.curl) [ "curl" ]
    ++ linkBins "/usr/bin" pkgs.which [ "which" ]
    ++ linkBins "/usr/bin" pkgs.findutils [
      "find"
      "xargs"
    ]
    ++ linkBins "/usr/bin" pkgs.diffutils [
      "diff"
      "cmp"
    ]
    ++ linkBins "/usr/bin" pkgs.gnutar [ "tar" ]
    ++ linkBins "/usr/bin" pkgs.gzip [
      "gzip"
      "gunzip"
    ];
}
