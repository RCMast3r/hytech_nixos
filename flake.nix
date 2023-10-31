{
  description = "Build image";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  outputs = { self, nixpkgs }: rec {
    nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
      modules = [ 
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
        
          systemd.services.sshd.wantedBy = nixpkgs.lib.mkOverride 40 [ "multi-user.target" ];
          services.openssh = {
            enable = true;
          };

          virtualisation.docker.enable = true;
          users.users.nixos.extraGroups = [ "docker" ];
          virtualisation.docker.rootless = {
            enable = true;
            setSocketVariable = true;
          };


        }
        
        ];
    }; 
    images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
  };
}