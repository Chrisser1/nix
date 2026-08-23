{ ... }: {
  flake.homeModules.tailnet = { pkgs, lib, config, options, ... }: {
    home.packages = [ pkgs.openssh pkgs.glib pkgs.xdg-user-dirs pkgs.xdg-utils ];

    programs = lib.optionalAttrs (options.programs ? noctalia) {
      noctalia.settings.plugins.enabled = [ "rylos/tailnet" ];
    };

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter ''
      hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("noctalia msg panel-toggle rylos/tailnet:panel"))
    '');
  };
}
