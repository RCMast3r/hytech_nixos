# Import the NixOS options
{ config, lib, nixpkgs, ... }:

{
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        imports = [
          ./modules/data_acq.nix
        ]
        ({ ... }: {
          config = {
            # ...like <hostname>
            sdImage.compressImage = false;

            # ... other configs

            # stateVersion = "23.11";
          };
          options = {
            services.data_writer.options.enable = true;
          };
        })
        {

          # nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";

          systemd.services.sshd.wantedBy =
            nixpkgs.lib.mkOverride 40 [ "multi-user.target" ];
          services.openssh = { enable = true; };

          virtualisation.docker.enable = true;
          users.users.nixos.extraGroups = [ "docker" ];
          virtualisation.docker.rootless = {
            enable = true;
            setSocketVariable = true;
          };

          users.extraUsers.nixos.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSt9Z8Qdq068xj/ILVAMqmkVyUvKCSTsdaoehEZWRut rcmast3r1@gmail.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhMu3LzyGPjh0WkqV7kZYwA+Hyd2Bfc+1XQJ88HeU4A rcmast3r1@gmail.com"
          ];

          networking.wireless = {
            enable = true;
            interfaces = [ "wlan0" ];
            networks = { "bens room" = { psk = "changeme"; }; };
          };
          networking.defaultGateway.address = "192.168.86.1";
          networking.nameservers = # Set DNS servers
            [ "8.8.8.8" "8.8.4.4" ];
          networking.interfaces.wlan0.ipv4.addresses = [{
            address = "192.168.86.69";
            prefixLength = 24;
          }];
          systemd.services.wpa_supplicant.wantedBy =
            nixpkgs.lib.mkOverride 10 [ "default.target" ];

          # NTP time sync.
          services.timesyncd.enable = true;

          nixpkgs.overlays = [ (hytech_data_acq.overlays.default) ];

        }
}