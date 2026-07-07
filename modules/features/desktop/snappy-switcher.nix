{ inputs, ... }: {
  flake.homeModules.snappy-switcher = { pkgs, lib, ... }: 
  let
    snappy = inputs.snappy-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    home.packages = [snappy];

    xdg.configFile."snappy-switcher/config.ini".text = ''
      [general]
      mode = context
      show_workspace_badge = true
      follow_monitor = true

      [theme]
      name = noctalia.ini

      [icons]
      theme = Adwaita
      fallback = hicolor
      show_letter_fallback = true
    '';

    # Rendered by Noctalia into ~/.config/snappy-switcher/themes/noctalia.ini
    # (registered under [theme.templates.user.snappy-switcher] in assets/noctalia-config.toml)
    xdg.configFile."noctalia/templates/snappy-switcher.ini".text = ''
      [colors]
      background = {{colors.surface.default.hex}}ee
      card_bg = {{colors.surface_container.default.hex}}ff
      card_selected = {{colors.surface_container_high.default.hex}}ff
      text_color = {{colors.on_surface.default.hex}}ff
      subtext_color = {{colors.on_surface_variant.default.hex}}ff
      border_color = {{colors.primary.default.hex}}ff
      bundle_bg = {{colors.surface_container.default.hex}}cc
      badge_bg = {{colors.secondary_container.default.hex}}ff
      badge_text_color = {{colors.on_secondary_container.default.hex}}ff
      badge_bg_selected = {{colors.primary.default.hex}}ff
      badge_text_color_selected = {{colors.on_primary.default.hex}}ff
    '';

    # The daemon reads config + theme once at startup; Noctalia's post_hook
    # restarts this service whenever the palette changes.
    systemd.user.services.snappy-switcher = {
      Unit = {
        Description = "Snappy Switcher window switcher daemon";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${snappy}/bin/snappy-switcher --daemon";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    home.activation.snappySwitcherThemeDir = lib.hm.dag.entryBefore ["writeBoundary"] ''
      mkdir -p "$HOME/.config/snappy-switcher/themes"
    '';
  };
}
