{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.keyValue { };
  inherit (lib) mkOption;
  inherit (lib.types)
    bool
    commas
    either
    enum
    nonEmptyStr
    separatedString
    submodule
    ;
in
{
  options.services.firewalld.settings = mkOption {
    description = ''
      FirewallD config file.  See {manpage}`firewalld.conf(5)`.
    '';
    default = { };
    type = submodule {
      freeformType = format.type;
      options = {
        DefaultZone = mkOption {
          type = nonEmptyStr;
          description = "";
          default = "public";
        };
        CleanupOnExit = mkOption {
          type = bool;
          description = "";
          default = true;
        };
        CleanupModulesOnExit = mkOption {
          type = bool;
          description = "";
          default = false;
        };
        IPv6_rpfilter = mkOption {
          type = enum [
            "strict"
            "loose"
            "strict-forward"
            "loose-forward"
            "no"
          ];
          description = "";
          default = "strict";
        };
        IndividualCalls = mkOption {
          type = bool;
          description = "";
          default = false;
        };
        LogDenied = mkOption {
          type = enum [
            "all"
            "unicast"
            "broadcast"
            "multicast"
            "off"
          ];
          description = "";
          default = "off";
        };
        FirewallBackend = mkOption {
          type = enum [
            "nftables"
            "iptables"
          ];
          description = "";
          default = "nftables";
        };
        FlushAllOnReload = mkOption {
          type = bool;
          description = "";
          default = true;
        };
        ReloadPolicy = mkOption {
          type =
            let
              policy = enum [
                "DROP"
                "REJECT"
                "ACCEPT"
              ];
            in
            either policy commas;
          description = "";
          default = "INPUT:DROP,FORWARD:DROP,OUTPUT:DROP";
        };
        RFC3964_IPv4 = mkOption {
          type = bool;
          description = "";
          default = true;
        };
        StrictForwardPorts = mkOption {
          type = bool;
          description = "";
          default = false;
        };
        NftablesFlowtable = mkOption {
          type = separatedString " ";
          description = "";
          default = "off";
        };
        NftablesCounters = mkOption {
          type = bool;
          description = "";
          default = false;
        };
        NftablesTableOwner = mkOption {
          type = bool;
          description = "";
          default = true;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."firewalld/firewalld.conf" = {
      source = format.generate "firewalld.conf" cfg.settings;
    };
  };
}
