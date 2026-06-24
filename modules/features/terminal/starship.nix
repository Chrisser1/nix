{ self, ... }: {
  flake.homeModules.starship = {
    config,
    pkgs,
    lib,
    ...
  }: {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };
}
