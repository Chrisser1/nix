{ self, ... }: 
let 
    vars = builtins.fromJSON (builtins.readFile ./cluster-vars.json);
in {
  flake.homeModules.ssh = { config, lib, ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*" = {};

        "${vars.controlPlaneSshAlias}" = {
          HostName = vars.controlPlaneIp;
          User = vars.controlPlaneSshUser;
          IdentityFile = vars.controlPlaneSshKey;
          IdentitiesOnly = "yes";
        };
      };
    };
  };
}