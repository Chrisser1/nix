{ ... }: {
  flake.homeModules.wayscriber = { pkgs, lib, ... }: {
    home.packages = [ pkgs.wayscriber ];

    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("wayscriber --daemon")
      end)
      hl.bind(mod .. " + D", hl.dsp.exec_cmd("wayscriber --daemon-toggle"))
    '';
  };
}
