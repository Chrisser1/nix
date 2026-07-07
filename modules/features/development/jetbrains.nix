{ ... }: {
  flake.homeModules.jetbrains = { pkgs, ... }:
  let
    # Official JetBrains native Wayland mode: forceWayland makes the launcher
    # pass -Dawt.toolkit.name=WLToolkit when WAYLAND_DISPLAY is set, so the IDE
    # runs natively under Hyprland instead of Xwayland (fixes popup placement).
    withWayland = ide: ide.override { forceWayland = true; };
  in {
    home.packages = map withWayland (with pkgs.jetbrains; [
      datagrip
      idea
      # goland
    ]);
  };
}
