{self, ...}: {
  flake.homeModules.laptop-home = {
    config,
    pkgs,
    inputs,
    lib,
    ...
  }: {
    home.stateVersion = "26.05";
  };
}
