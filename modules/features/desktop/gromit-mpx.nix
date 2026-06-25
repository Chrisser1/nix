{self, ...}: {
  flake.homeModules.gromit-mpx = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.gromit-mpx];

    home.file.".config/gromit-mpx.cfg".text = ''
      "red pen"    = PEN (size=5 color="red");
      "blue pen"   = PEN (size=5 color="blue");
      "green pen"  = PEN (size=5 color="green");
      "red arrow"  = LINE (size=3 color="red" arrowsize=1);
      "eraser"     = ERASER (size=50);

      "default"           = "red pen";
      "default"[SHIFT]    = "blue pen";
      "default"[ALT]      = "red arrow";
      "default"[CONTROL]  = "eraser";
    '';

    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      hl.bind(mod .. " + D",      hl.dsp.exec_cmd("gromit-mpx -a"))
      hl.bind(mod .. " + Z",      hl.dsp.exec_cmd("gromit-mpx -z"))
      hl.bind(mod .. " + Y",      hl.dsp.exec_cmd("gromit-mpx -y"))
      hl.bind(mod .. " + Delete", hl.dsp.exec_cmd("gromit-mpx -c"))
    '';
  };
}
