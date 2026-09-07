{ ... }: {
  flake.homeModules.screenshot-satty = { pkgs, lib, options, ... }:
  let
    satty = "${pkgs.satty}/bin/satty";
    wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";

    # noctalia runs this via `/bin/sh -lc` with the captured PNG on stdin, so
    # spell out store paths instead of relying on the login shell's PATH.
    pipeCommand = lib.concatStringsSep " " [
      satty
      "--filename -"
      "--output-filename ~/Pictures/screenshot_%Y%m%d_%H%M%S.png"
      "--copy-command ${wlCopy}"
      "--early-exit"
    ];
  in {
    programs = lib.optionalAttrs (options.programs ? noctalia) {
      # satty owns saving and the clipboard: noctalia only captures the region
      # and hands the PNG over, so one annotated file lands per screenshot.
      noctalia.settings.shell.screenshot = {
        annotate = false;
        copy_to_clipboard = false;
        pipe_command = pipeCommand;
        pipe_to_command = true;
        save_to_file = false;
      };
    };
  };
}
