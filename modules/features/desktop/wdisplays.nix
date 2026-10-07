{ ... }: {
  # Layouts are saved by nyx-monitors, so this only provides the GUI.
  flake.homeModules.wdisplays = {pkgs, ...}: {
    home.packages = [
      pkgs.wdisplays
      pkgs.wlr-randr
    ];
  };
}
