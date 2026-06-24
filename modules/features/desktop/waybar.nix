{ self, inputs, ... }: {
  flake.homeModules.waybar = { config, pkgs, lib, ... }: 
  let
    scripts = import ../../../config/waybar/scripts.nix { inherit pkgs; };
    barConfig = import ../../../config/waybar/config.nix { inherit pkgs scripts; };
  in {
    home.packages = with pkgs; [
      pavucontrol 
      libnotify
      scripts.wallpaperLabel
      scripts.wallpaperPicker
      scripts.getWatts
      scripts.launchWaybar
    ];

    programs.waybar = {
      enable = true;
      settings = barConfig;
    };

    home.file.".config/waybar/mocha.css".text  = builtins.readFile ../../../config/waybar/mocha.css;
    home.file.".config/waybar/style.css".text  = builtins.readFile ../../../config/waybar/style.css;
  };
}