{ self, ... }: let
  vars = builtins.fromJSON (builtins.readFile ./cluster-vars.json);
in {
  flake.homeModules.ssh = { config, lib, ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings =
        {"*" = {};}
        // builtins.listToAttrs (map (server: {
            name = server.sshAlias;
            value = {
              HostName = server.ip;
              User = server.sshUser;
              IdentityFile = server.sshKey;
              IdentitiesOnly = "yes";
            };
          })
          vars.servers);
    };
  };
}
