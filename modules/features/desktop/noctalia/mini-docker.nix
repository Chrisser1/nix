{ ... }: {
  flake.homeModules.mini-docker = { lib, config, options, ... }: {
    programs = lib.optionalAttrs (options.programs ? noctalia) {
      noctalia.settings.plugins.enabled = [ "8bury/mini-docker" ];
    };

    wayland.windowManager.hyprland.extraConfig = lib.mkIf config.wayland.windowManager.hyprland.enable (lib.mkAfter ''
      hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd("noctalia msg panel-toggle 8bury/mini-docker:manager"))
    '');
  };
}
