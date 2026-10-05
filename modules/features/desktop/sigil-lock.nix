{ inputs, ... }: {
  flake.homeModules.sigil-lock = { pkgs, lib, osConfig, ... }:
  let
    sigil = lib.findFirst (p: lib.hasPrefix "sigil-sddm-theme" (p.name or ""))
      (throw "sigil-lock: programs.sigil-sddm must be enabled")
      osConfig.services.displayManager.sddm.extraPackages;
    shell = "${inputs.qylock}/quickshell-lockscreen";

    sigilLock = pkgs.writeShellScriptBin "sigil-lock" ''
      export QS_THEME=sigil
      export QS_THEME_PATH=${sigil}/share/sddm/themes/sigil
      # qylock's shims (QtMultimedia, SddmComponents) first, then the Sigil plugin.
      export QML2_IMPORT_PATH="${shell}/imports:${sigil}/lib/qt-6/qml''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
      # The shim reads the theme's theme.conf over XHR.
      export QML_XHR_ALLOW_FILE_READ=1
      export XDG_SESSION_TYPE=''${XDG_SESSION_TYPE:-wayland}

      # One lock at a time: Mod+L, lock-session and before-sleep can overlap.
      exec ${pkgs.util-linux}/bin/flock -n "''${XDG_RUNTIME_DIR:-/tmp}/sigil-lock.lock" \
        ${pkgs.quickshell}/bin/quickshell -p ${shell}/lock_shell.qml
    '';
    lock = "${sigilLock}/bin/sigil-lock";
  in {
    home.packages = [ sigilLock ];

    services.swayidle = {
      enable = true;
      events = {
        lock = "${lock} &";
        # sigil-lock runs until unlocked; give the lock surface a moment to map
        # before swayidle releases the sleep inhibitor.
        before-sleep = "${lock} & sleep 1";
      };
    };
  };
}
