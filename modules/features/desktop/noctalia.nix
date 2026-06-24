{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.noctalia = {...}: {
    imports = [inputs.noctalia.nixosModules.default];
    programs.noctalia = {
      enable = true;
      package = null;
      recommendedServices.enable = true;
    };
  };

  flake.homeModules.noctalia = {...}: {
    imports = [inputs.noctalia.homeModules.default];
    programs.noctalia = {
      enable = true;
      settings = builtins.readFile "${self}/assets/noctalia-config.toml";
    };
  };
}
