{ self, ... }: {
  flake.homeModules.laptop-home = { config, pkgs, inputs, lib, ... }: {
    home.stateVersion = "25.05";
    
    wayland.windowManager.hyprland.settings = {
      monitor = ["eDP-1,2880x1800@120,0x0,2"];
      exec-once = lib.mkAfter [
        "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 1"
      ];
    };
  };
}