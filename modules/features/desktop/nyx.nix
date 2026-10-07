{ self, inputs, ... }: {
  flake.nixosModules.nyx = { ... }: {
    imports = [ inputs.nyx.nixosModules.default ];
    programs.nyx.calendar.enable = true;
  };

  # The nyx shell (~/repos/nyx). To return to noctalia, import nixosModules.noctalia
  # in hosts/shared.nix and swap this for noctalia-desktop in profiles.nix.
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

    # Backs the nyx Bitwarden launcher mode. nyx-bitwarden writes rbw's config
    # (email, region, pinentry) at login, so it must stay mutable and not come
    # from programs.rbw.
    home.packages = [ pkgs.rbw ];

    # noctalia replaced these with mutable copies.
    xdg.configFile."gtk-3.0/gtk.css".force = true;
    xdg.configFile."gtk-4.0/gtk.css".force = true;

    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("nyx-shell -d")
        hl.exec_cmd("nyx-monitors restore")
        hl.exec_cmd("nyx-monitors watch")
        hl.exec_cmd("nyx-wallpaper restore")
      end)

      -- Rendered by nyx-theme; absent until the first theme is applied.
      pcall(dofile, _hypr_dir .. "/nyx-theme.lua")

      -- The nyx keybinds come from programs.nyx.keybinds.
    '';
  };
}
