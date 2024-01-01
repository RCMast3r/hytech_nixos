{
  description = "Build image";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    hytech_data_acq.url = "github:RCMast3r/data_acq";
  };
  outputs = { self, nixpkgs, hytech_data_acq }: rec {
    
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
        "./modules/data_acq.nix"
        
        ];
    };
    
    nixosConfigurations.rpi3 = nixpkgs.lib.nixosSystem {
      modules = [ 
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        ./modules/data_acq.nix
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
          nixpkgs.overlays = 
            [(hytech_data_acq.overlays.default)];
          
        }
        
        
        ];
    }; 
    images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
    images.rpi3 = nixosConfigurations.rpi3.config.system.build.sdImage;
  };
}