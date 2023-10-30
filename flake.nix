{
  description = "Build image";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  outputs = { self, nixpkgs }: rec {
    nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
      modules = [ 
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
        {
          nixpkgs.config.allowUnsupportedSystem = true;
          nixpkgs.hostPlatform.system = "aarch64-linux";
          nixpkgs.buildPlatform.system = "x86_64-linux";
        } 
        ];
      systemd.sshd.enable = true;
    }; 
    images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
  };
}