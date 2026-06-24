{self, ...}: {
  flake.homeModules.laptop-home = {
    config,
    pkgs,
    inputs,
    lib,
    ...
  }: {
    home.stateVersion = "26.05";

    wayland.windowManager.hyprland.extraConfig = ''
      hl.monitor({
        output   = "eDP-1",
        mode     = "2880x1800@120",
        position = "0x0",
        scale    = 2,
      })
    '';
  };
}
