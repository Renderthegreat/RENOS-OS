{ pkgs }: {
  deps = [
    pkgs.nasm
    pkgs.cdrtools
    pkgs.wget
    pkgs.qemu_kvm
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.man
  ];
}