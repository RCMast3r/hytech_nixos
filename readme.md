pre-reqs:

- for non-nixOs systems that have the nix package manager installed:
- enable nix flakes

install `qemu-user-static` package then in `/etc/nix/nix.conf` add:
`extra-platforms = aarch64-linux arm-linux` and restart `nix-daemon.service`


- to build the flake defined image: `nix build .#images.rpi4 --system aarch64-linux`

- to build locally with the copy-closure workflow: 

1. build with either
    - `nix build .#nixosConfigurations.rpi3.config.system.build.toplevel --system aarch64-linux`
or
    - `nix build .#nixosConfigurations.rpi4.config.system.build.toplevel --system aarch64-linux` for the pi 4
2. `nix-copy-closure --to nixos@192.168.143.69 result/` (will have store path as part of output to switch to)
3. (ssh into pi)
4. `sudo /nix/store/<hash>-nixos-system-<version>/bin/switch-to-configuration switch`
5. profit


TODO:
- [ ] initialize CAN correctly (`networking.interfaces`)
    - enable device tree overlay for spi CAN adapter
    - nixos uses systemd for network setup instead of the ip tool
    - https://wiki.archlinux.org/title/systemd-networkd
    - https://pengutronix.de/en/blog/2022-02-04-initializing-can-interfaces-with-systemd-networkd.html
    - https://www.freedesktop.org/software/systemd/man/latest/systemd.network.html#[CAN]%20Section%20Options
    
- [ ] set static ip for the pi and enable wireless networking for connecting
- [ ] setup copy-closure workflow for nixos iteration: https://discourse.nixos.org/t/copy-nix-store-to-another-machine/15549

notes:

pushing to cachix (via emulated aarch64-linux):
(after following the registration steps for pushing)
```
nix build --system aarch64-linux --json \
  | jq -r '.[].outputs | to_entries[].value' \
  | cachix push rcmast3r
```
