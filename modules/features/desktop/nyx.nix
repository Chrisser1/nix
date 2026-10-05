{ self, inputs, ... }: {
  flake.nixosModules.nyx = { ... }: {
    imports = [ inputs.nyx.nixosModules.default ];
    programs.nyx.calendar.enable = true;
  };

  # The nyx shell (~/repos/nyx). Swapped in for noctalia-desktop in profiles.nix.
  flake.homeModules.nyx = { pkgs, lib, ... }: {
    imports = [ inputs.nyx.homeModules.default ];

    programs.nyx = {
      enable = true;
      hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      terminal = "kitty";
      lockCommand = "sigil-lock";
      wallpaper = {
        directory = "${self}/assets/backgrounds";
        default = "animated/large-cherry-blossom-tree.3840x2160.mp4";
      };
      theme = {
        scheme = "gruvbox-dark-medium";
        accent = "base0B";
      };
    };

    services.cliphist.enable = false;

    # noctalia replaced these with mutable copies.
    xdg.configFile."gtk-3.0/gtk.css".force = true;
    xdg.configFile."gtk-4.0/gtk.css".force = true;

    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("nyx-shell -d")
        hl.exec_cmd("nyx-wallpaper restore")
      end)

      -- Rendered by nyx-theme; absent until the first theme is applied.
      pcall(dofile, _hypr_dir .. "/nyx-theme.lua")

      local function nyx(name) return hl.dsp.global("nyx:" .. name) end

      hl.bind(mod .. " + SHIFT +S",   hl.dsp.exec_cmd("nyx-screenshot region"))
      hl.bind(mod .. " + U",         nyx("togglePower"))
      hl.bind(mod .. " + V",         nyx("toggleClipboard"))
      hl.bind(mod .. " + T",         nyx("toggleSystem"))
      hl.bind(mod .. " + R",         nyx("toggleLauncher"))
      hl.bind("ALT + Space",         nyx("toggleLauncher"))
      hl.bind(mod .. " + W",         nyx("toggleWallpaper"))
      hl.bind(mod .. " + M",         nyx("toggleDisplays"))
      hl.bind(mod .. " + N",         nyx("toggleNotifications"))
      hl.bind(mod .. " + BackSpace", nyx("discardLastNotification"))

      hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("nyx-kbd-backlight cycle"), { locked = true })
      hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("nyx-kbd-backlight cycle"), { locked = true })
      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("nyx-brightness up"),   { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("nyx-brightness down"), { locked = true, repeating = true })
      hl.bind("XF86AudioMute",        nyx("toggleMute"),      { locked = true })
      hl.bind("XF86AudioLowerVolume", nyx("decrementVolume"), { locked = true, repeating = true })
      hl.bind("XF86AudioRaiseVolume", nyx("incrementVolume"), { locked = true, repeating = true })
    '';
  };
}
