pre-reqs:

- for non-nixOs systems that have the nix package manager installed:

install `qemu-user-static` package then in `/etc/nix/nix.conf` add:
`extra-platforms = aarch64-linux arm-linux` and restart `nix-daemon.service`


1. to build: `nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./sd-image.nix --argstr system aarch64-linux`



