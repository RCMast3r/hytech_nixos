{ lib, pkgs, config, ... }:
with lib;                      
let
  # Shorter name to access final settings a 
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.services.data_writer;
in {
  options.services.data_writer = {
    enable = mkEnableOption "data writer service";
    # greeter = mkOption {
    #   type = types.str;
    #   default = "world";
    # };
  };

  # Define what other settings, services and resources should be active IF
  # a user of this "hello.nix" module ENABLED this module 
  # by setting "services.hello.enable = true;".
  config = mkIf cfg.enable {
    systemd.services.data_writer = {
      wantedBy = [ "multi-user.target" ];
      After = [ "network.target" ];
      serviceConfig.ExecStart = "${pkgs.py_data_acq_pkg}/bin/python3 ${pkgs.py_data_acq_pkg}/bin/data_acq_service.py";
    };
  };
}