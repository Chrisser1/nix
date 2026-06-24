{self, ...}: {
  flake.homeModules.gui-terminal = {pkgs, ...}: {
    programs.kitty = {
      enable = true;
      font = {
        name = "CaskaydiaCove Nerd Font";
        size = 12;
      };
      settings = {
        enable_audio_bell = false;
        window_padding_width = 4;
        hide_window_decorations = "yes";
      };
      extraConfig = "include themes/noctalia.conf";
    };
  };
}
