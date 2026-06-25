{ self, ... }: {
  flake.homeModules.gromit-mpx = { pkgs, lib, ... }: {
    home.packages = [pkgs.gromit-mpx];

    home.file.".config/gromit-mpx.cfg".text = ''
      "default"         = PEN (size=5 red=1.0 green=0.0 blue=0.0);
      "default" SHIFT   = PEN (size=5 red=0.0 green=0.0 blue=1.0);
      "default" ALT     = LINE (size=3 red=1.0 green=0.0 blue=0.0 arrowsize=1);
      "default" CONTROL = ERASER (size=50);
    '';

    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("gromit-mpx -d")
      end)

      hl.bind(mod .. " + D", hl.dsp.exec_cmd("gromit-mpx -t"))
    '';
  };
}
