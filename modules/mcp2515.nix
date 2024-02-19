{ config, lib, pkgs, ... }:

{
  # Assuming your system uses these kernel modules
  boot.kernelModules = [ "spi-bcm2835" "can-dev" "can-raw" "mcp251x" ];

  # Device tree overlay configuration
  hardware.deviceTree = {
    enable = true;
    overlays = [
      # Specify your device tree overlay here
      "${pkgs.path}/path/to/your/overlay.dtb"
    ];
  };
}
