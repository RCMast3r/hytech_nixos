pre-reqs:

- for non-nixOs systems that have the nix package manager installed:

install `qemu-user-static` package then in `/etc/nix/nix.conf` add:
`extra-platforms = aarch64-linux arm-linux` and restart `nix-daemon.service`


- to build the regular sd-image: `nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage -I nixos-config=./sd-image.nix --argstr system aarch64-linux`

- to build the flake defined image: `nix build .#images.rpi4 --system aarch64-linux`


TODO:
- [ ] initialize CAN correctly (`networking.interfaces`)
    - enable device tree overlay for spi CAN adapter
    - nixos uses systemd for network setup instead of the ip tool
    - https://wiki.archlinux.org/title/systemd-networkd
    - https://pengutronix.de/en/blog/2022-02-04-initializing-can-interfaces-with-systemd-networkd.html
    - https://www.freedesktop.org/software/systemd/man/latest/systemd.network.html#[CAN]%20Section%20Options
    
- [ ] set static ip for the pi and enable wireless networking for connecting
- [ ] setup copy-closure workflow for nixos iteration: https://discourse.nixos.org/t/copy-nix-store-to-another-machine/15549