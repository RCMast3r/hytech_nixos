{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.can;
  ipCmd = "${pkgs.iproute2}/bin/ip";
in
{
  options.networking.can = {
    enable = mkEnableOption "CAN network interfaces";

    interfaces = mkOption {
      default = {};
      example = literalExpression ''{
        can0 = {
          bitrate = 500000;
        };
      }'';
      type = types.attrsOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "The name of the CAN interface.";
          };
          bitrate = mkOption {
            type = types.int;
            default = 500000;
            description = "The bitrate of the CAN interface.";
          };
        };
      });
      description = "CAN interface configurations.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.can-setup = {
      description = "CAN Network Interfaces Setup";
      wantedBy = [ "multi-user.target" ];
      before = [ "network.target" ];
      script = concatStringsSep "\n" (mapAttrsToList (name: iface: ''
        ${ipCmd} link set ${name} type can bitrate ${toString iface.bitrate}
        ${ipCmd} link set up ${name}
      '') cfg.interfaces);
      path = [ pkgs.iproute2 ];
    };
  };
}
