{
  description = "Build image";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    hytech_data_acq.url = "github:RCMast3r/data_acq";
  };
  outputs = { self, nixpkgs, hytech_data_acq }: rec {


    ontarget_options = {
      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;
      users.users.nixos.isNormalUser = true;
      users.users.nixos.group = "nixos";
      users.groups.nixos = { };
    };
    shared_config = {
      nixpkgs.overlays = [ (hytech_data_acq.overlays.default) ];

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
      services.openssh.listenAddresses =[
        {
          addr = "0.0.0.0";
          port = 22;
        }
        {
          addr = ":";
          port = 22;
        }
      ];
      # users.extraUsers.nixos.password = "password";
      users.extraUsers.nixos.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSt9Z8Qdq068xj/ILVAMqmkVyUvKCSTsdaoehEZWRut rcmast3r1@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhMu3LzyGPjh0WkqV7kZYwA+Hyd2Bfc+1XQJ88HeU4A rcmast3r1@gmail.com"
      ];
      networking.enableIPv6 = true;
      # users.extraUsers.nixos.openssh.extraConfig = "AddressFamily = any";
      # networking.hostname = "hytech-pi";
      networking.wireless = {
        enable = true;
        interfaces = [ "wlan0" ];
        networks = { "yo" = { psk = "11111111"; }; };
      };

      # networking.defaultGateway.address = "192.168.84.243";
      networking.interfaces.wlan0.ipv4.addresses = [{
        address = "192.168.143.69";
        prefixLength = 24;
      }];
      systemd.services.wpa_supplicant.wantedBy =
        nixpkgs.lib.mkOverride 10 [ "default.target" ];

      # NTP time sync.
      services.timesyncd.enable = true;
      programs.git = {
        enable = true;
        config = {
          user.name = "Ben Hall";
          user.email = "rcmast3r1@gmail.com";

        };
      };

    };

    nixosConfigurations.rpi3_ontarget = nixpkgs.lib.nixosSystem {
      modules = [
        ./modules/data_acq.nix
        ./hw/hw-conf.nix
        (
          { ... }: {
            options = {
              services.data_writer.options.enable = true;
            };
          }
        )
        (ontarget_options)
        (shared_config)
      ];
    };

    nixosConfigurations.rpi3 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux"; 
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        ./modules/data_acq.nix
        (
          { ... }: {
            config = {
              sdImage.compressImage = false;
            };
            options = {
              services.data_writer.options.enable = true;

            };

          }
        )
        (shared_config)
      ];
    };
    images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
    images.rpi3 = nixosConfigurations.rpi3.config.system.build.sdImage;
  };
}
