{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {
    pkgs,
    lib,
    ...
  }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    # NIRI
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      passthru.providedSessions = ["niri"];

      settings = {
        spawn-at-startup = [
          "noctalia --daemon"
        ];

        # System mapping
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
        input.keyboard.xkb.layout = "dk";

        # Visuals (Matched your Hyprland gaps and borders)
        layout = {
          gaps = 2;
          border = {
            width = 2;
            active-color = "#880808";
            inactive-color = "#595959";
          };
        };

        binds = {
          # --- Apps & Scripts ---
          "Mod+S".spawn-sh = "${pkgs.firefox}/bin/firefox";
          "Mod+Q".spawn-sh = "${pkgs.kitty}/bin/kitty";
          "Mod+U".spawn-sh = "powermenu";
          "Mod+R".spawn-sh = "rofi -show drun";
          "Alt+Space".spawn-sh = "rofi -show drun";
          "Mod+E".spawn-sh = "${pkgs.nautilus}/bin/nautilus";
          "Mod+V".spawn-sh = "berserk-clipboard";
          "Mod+M".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

          # --- Window Management ---
          "Mod+Shift+C".close-window = [];
          "Mod+Space".toggle-window-floating = [];

          # --- Focus (Arrows) ---
          "Mod+Left".focus-column-left = [];
          "Mod+Right".focus-column-right = [];
          "Mod+Up".focus-window-up = [];
          "Mod+Down".focus-window-down = [];

          # --- Move Windows (Shift + Arrows) ---
          "Mod+Shift+Left".move-column-left = [];
          "Mod+Shift+Right".move-column-right = [];
          "Mod+Shift+Up".move-window-up = [];
          "Mod+Shift+Down".move-window-down = [];

          # --- Workspaces (1-9) ---
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;

          # --- Move to Workspace (Shift + 1-9) ---
          "Mod+Shift+1".move-column-to-workspace = 1;
          "Mod+Shift+2".move-column-to-workspace = 2;
          "Mod+Shift+3".move-column-to-workspace = 3;
          "Mod+Shift+4".move-column-to-workspace = 4;
          "Mod+Shift+5".move-column-to-workspace = 5;
          "Mod+Shift+6".move-column-to-workspace = 6;
          "Mod+Shift+7".move-column-to-workspace = 7;
          "Mod+Shift+8".move-column-to-workspace = 8;
          "Mod+Shift+9".move-column-to-workspace = 9;
        };
      };
    };
  };
}
