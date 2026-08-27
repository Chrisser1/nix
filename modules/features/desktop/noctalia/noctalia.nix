{ self, inputs, ... }: {
  flake.nixosModules.noctalia = {...}: {
    imports = [inputs.noctalia.nixosModules.default];
    disabledModules = ["programs/wayland/noctalia.nix"];
    nix.settings.extra-substituters = ["https://noctalia.cachix.org"];
    nix.settings.extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    programs.noctalia = {
      enable = true;
      package = null;
      recommendedServices.enable = true;
    };
  };

  flake.homeModules.noctalia = { pkgs, lib, ... }: 
  let
    system = pkgs.stdenv.hostPlatform.system;
    hyprctl = "${inputs.hyprland.packages.${system}.hyprland}/bin/hyprctl";

    # The gslapper plugin shells out to a bare `gst-launch-1.0` to build video
    # thumbnails for the picker, so it needs decoders on GST_PLUGIN_SYSTEM_PATH.
    gstPlugins = with pkgs.gst_all_1; [gstreamer.out gst-plugins-base gst-plugins-good gst-plugins-bad gst-libav gst-plugins-ugly];
    gstLaunch = pkgs.symlinkJoin {
      name = "gst-launch-wrapped";
      paths = [pkgs.gst_all_1.gstreamer];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/gst-launch-1.0 \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}"
      '';
    };
    gslapper = inputs.gslapper.packages.${system}.default.overrideAttrs (_: {
      postFixup = ''
        wrapProgram $out/bin/gslapper \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}"
      '';
    });

    noctaliaHyprExtra = pkgs.writeShellScriptBin "noctalia-hypr-extra" ''
      colors="$HOME/.config/noctalia/colors.json"
      out="$HOME/.config/hypr/noctalia-extra.lua"
      get() { awk -F'"' -v k="$1" '$2==k{gsub("#","",$(NF-1));print $(NF-1)}' "$colors" 2>/dev/null; }
      if [ -f "$colors" ]; then
        on_sec=$(get mOnSecondary)
        on_surf=$(get mOnSurface)
      fi
      on_sec=''${on_sec:-000000}
      on_surf=''${on_surf:-d1d1c7}

      # Persist for next hyprland startup
      printf 'hl.config({ group = { groupbar = { text_color = "rgb(%s)", text_color_inactive = "rgb(%s)" } } })\n' \
        "$on_sec" "$on_surf" > "$out"

      # Apply immediately at runtime, avoids race with noctalia.lua reload debounce
      hypr_sig=$(ls /run/user/$(id -u)/hypr/ 2>/dev/null | head -1)
      if [ -n "$hypr_sig" ]; then
        HYPRLAND_INSTANCE_SIGNATURE="$hypr_sig" ${hyprctl} keyword group:groupbar:text_color "rgb(''${on_sec})"
        HYPRLAND_INSTANCE_SIGNATURE="$hypr_sig" ${hyprctl} keyword group:groupbar:text_color_inactive "rgb(''${on_surf})"
      fi
    '';

    # noctalia overlays $XDG_STATE_HOME/noctalia/settings.toml on top of the
    # declarative config.toml, and deepMerge replaces arrays wholesale rather
    # than merging them. A stale table written by the settings GUI therefore
    # shadows this flake forever -- e.g. an old [bar.*] silently drops any
    # capsule group added later. Prune the GUI-writable tables on activation so
    # assets/noctalia-config.toml stays the source of truth; wallpaper picks and
    # config_version are app-managed state and stay put.
    noctaliaPruneOverrides = pkgs.writeShellScriptBin "noctalia-prune-overrides" ''
      state="''${NOCTALIA_STATE_HOME:-''${XDG_STATE_HOME:-$HOME/.local/state}}/noctalia"
      settings="$state/settings.toml"
      [ -f "$settings" ] || exit 0

      managed="bar calendar desktop_widgets dock location lockscreen_widgets plugin_settings plugins theme widget"

      tmp=$(mktemp)
      ${pkgs.gawk}/bin/awk -v managed=" $managed " '
        # Only column-0 headers open a section; indented ones belong to the
        # section above them.
        /^\[/ {
          head = $0
          sub(/^\[+/, "", head)
          root = match(head, /^[^.\]]+/) ? substr(head, 1, RLENGTH) : ""
          skip = index(managed, " " root " ") > 0
          if (skip) pruned[root] = 1
        }
        !skip
        END {
          for (k in pruned) list = list (list ? ", " : "") k
          if (list) print "noctalia: pruned stale runtime overrides: " list > "/dev/stderr"
        }
      ' "$settings" > "$tmp"

      # Write in place -- noctalia watches this file by path and reloads itself.
      cmp -s "$tmp" "$settings" || cat "$tmp" > "$settings"
      rm -f "$tmp"
    '';
  in {
    imports = [inputs.noctalia.homeModules.default];
    programs.noctalia = {
      enable = true;
      # Attrset (not raw TOML string) so other modules
      # can merge into settings. @FLAKE@ is substituted after parsing because
      # fromTOML rejects strings with store-path context.
      settings = let
        subst = v:
          if builtins.isString v
          then builtins.replaceStrings ["@FLAKE@"] ["${self}"] v
          else if builtins.isAttrs v
          then builtins.mapAttrs (_: subst) v
          else if builtins.isList v
          then map subst v
          else v;
      in
        subst (builtins.fromTOML (builtins.readFile "${self}/assets/noctalia-config.toml"));
    };

    home.packages = [
      noctaliaHyprExtra
      noctaliaPruneOverrides
      gstLaunch
      gslapper
    ];

    systemd.user.services.noctalia-hypr-extra = {
      Unit.Description = "Update Hyprland extra colors from Noctalia palette";
      Service = {
        Type = "oneshot";
        ExecStart = "${noctaliaHyprExtra}/bin/noctalia-hypr-extra";
      };
    };

    systemd.user.paths.noctalia-hypr-extra = {
      Unit.Description = "Watch Noctalia Hyprland config for palette changes";
      Path.PathModified = "%h/.config/hypr/noctalia.lua";
      Install.WantedBy = ["default.target"];
    };

    home.activation.noctaliaHyprConf = lib.hm.dag.entryBefore ["writeBoundary"] ''
      if [ ! -f "$HOME/.config/hypr/noctalia.lua" ]; then
        mkdir -p "$HOME/.config/hypr"
        touch "$HOME/.config/hypr/noctalia.lua"
      fi
      if [ ! -f "$HOME/.config/hypr/noctalia-extra.lua" ]; then
        mkdir -p "$HOME/.config/hypr"
        touch "$HOME/.config/hypr/noctalia-extra.lua"
      fi
      ${noctaliaHyprExtra}/bin/noctalia-hypr-extra || true
    '';

    home.activation.noctaliaPruneOverrides = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${noctaliaPruneOverrides}/bin/noctalia-prune-overrides || true
    '';
  };
}
