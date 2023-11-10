{ pkgs }: {
  deps = [
    pkgs.cdrkit
    pkgs.python39Packages.pip
    pkgs.python39Packages.cython
    pkgs.nasm
    pkgs.cdrtools
    pkgs.wget
    pkgs.qemu_kvm
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.man
  ];
}