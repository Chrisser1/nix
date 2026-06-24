{ self, ... }: {
  flake.homeModules.rofi = { pkgs, config, ... }: 
  let
    powermenu = pkgs.writeShellScriptBin "powermenu" ''
      #!/usr/bin/env bash
      
      entries="Lock\x00icon\x1fsystem-lock-screen\n"
      entries+="Logout\x00icon\x1fsystem-log-out\n"
      entries+="Suspend\x00icon\x1fsystem-suspend\n"
      entries+="Reboot\x00icon\x1fsystem-reboot\n"
      entries+="Shutdown\x00icon\x1fsystem-shutdown\n"
      entries+="Switch User\x00icon\x1fsystem-users\n"
      
      selected=$(printf "$entries" | rofi -dmenu -p "Power Menu" \
                    -theme-str 'window { width: 400px; }' \
                    -theme-str 'listview { lines: 6; }' \
                    -theme-str 'element-icon { size: 48px; }' \
                    -theme-str 'mainbox { children: [ "listview" ]; }')

      case "$selected" in
        "Lock") pidof hyprlock || hyprlock ;;
        "Logout") hyprctl dispatch exit ;;
        "Suspend") systemctl suspend ;;
        "Reboot") systemctl reboot ;;
        "Shutdown") systemctl poweroff ;;
        "Switch User") ${pkgs.lightdm}/bin/dm-tool switch-to-greeter ;;
        *) ;;
      esac
    '';
  in {
    home.packages = [ powermenu pkgs.lightdm pkgs.networkmanager_dmenu ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      extraConfig = {
        modi = "drun,run";
        show-icons = true;
        drun-display-format = "{icon} {name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        display-run = "   Run ";
        display-window = " 󰕰  Window";
        display-Network = " 󰤨  Network";
        sidebar-mode = true;
      };

      theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
        "*" = {
          background-color = mkLiteral "#171717";
          text-color = mkLiteral "#EDE6DB";      
          border-color = mkLiteral "#7F0909";    
        };
        "#window" = { width = mkLiteral "600px"; border = mkLiteral "2px"; padding = mkLiteral "10px"; border-radius = mkLiteral "0px"; background-color = mkLiteral "#171717"; };
        "#mainbox" = { background-color = mkLiteral "transparent"; children = map mkLiteral [ "inputbar" "listview" ]; };
        "#inputbar" = { children = map mkLiteral [ "prompt" "entry" ]; background-color = mkLiteral "#2B2B2B"; padding = mkLiteral "10px"; border = mkLiteral "1px"; border-radius = mkLiteral "0px"; margin = mkLiteral "0px 0px 10px 0px"; };
        "#entry" = { background-color = mkLiteral "transparent"; text-color = mkLiteral "#EDE6DB"; };
        "#prompt" = { background-color = mkLiteral "transparent"; text-color = mkLiteral "#EDE6DB"; padding = mkLiteral "0px 10px 0px 0px"; };
        "#listview" = { background-color = mkLiteral "transparent"; lines = 8; columns = 1; };
        "#element" = { padding = mkLiteral "8px"; text-color = mkLiteral "#EDE6DB"; background-color = mkLiteral "transparent"; };
        "#element selected" = { background-color = mkLiteral "#7F0909"; text-color = mkLiteral "#FFFFFF"; };
        "#element-icon" = { size = mkLiteral "24px"; padding = mkLiteral "0 10px 0 0"; background-color = mkLiteral "transparent"; };
        "#element-text" = { background-color = mkLiteral "transparent"; text-color = mkLiteral "inherit"; vertical-align = mkLiteral "0.5"; };
      };
    };

    xdg.configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = rofi -dmenu -p "Network"
      compact = True
      pinentry = rofi -dmenu -p "Password" -password
      wifi_icons = 󰤯󰤟󰤢󰤥󰤨

      [editor]
      terminal = kitty
      gui_if_available = True
    '';
  };
}