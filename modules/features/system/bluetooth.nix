{ ... }: {
  flake.nixosModules.bluetooth = { pkgs, ... }:
  let
    wireplumberPruneState = pkgs.writeShellScriptBin "wireplumber-prune-state" ''
      set -eu

      dry=0
      [ "''${1:-}" = "--dry-run" ] && dry=1

      state="''${XDG_STATE_HOME:-$HOME/.local/state}/wireplumber"
      [ -d "$state" ] || exit 0

      paired=$(${pkgs.bluez}/bin/bluetoothctl devices Paired 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $2}' | tr '\n' ' ')
      if [ -z "$paired" ]; then
        echo "wireplumber-prune-state: bluez returned no paired devices, refusing to prune" >&2
        exit 1
      fi

      # WirePlumber flushes its in-memory state on shutdown, so pruning a live
      # daemon just gets overwritten. Stop it first, edit, then bring it back.
      restart=0
      if [ "$dry" -eq 0 ] && ${pkgs.systemd}/bin/systemctl --user is-active --quiet wireplumber; then
        restart=1
        ${pkgs.systemd}/bin/systemctl --user stop wireplumber
      fi

      for f in default-nodes default-routes stream-properties; do
        [ -f "$state/$f" ] || continue
        tmp=$(mktemp)
        ${pkgs.gawk}/bin/awk -v paired="$paired" -v file="$f" '
          function norm(s) { gsub(/:/, "_", s); return toupper(s) }
          BEGIN {
            n = split(paired, p, " ")
            for (i = 1; i <= n; i++) if (p[i] != "") keep[norm(p[i])] = 1
          }
          /^\[/ { print; next }
          {
            if (match($0, /[0-9A-Fa-f][0-9A-Fa-f][:_][0-9A-Fa-f][0-9A-Fa-f][:_][0-9A-Fa-f][0-9A-Fa-f][:_][0-9A-Fa-f][0-9A-Fa-f][:_][0-9A-Fa-f][0-9A-Fa-f][:_][0-9A-Fa-f][0-9A-Fa-f]/)) {
              mac = norm(substr($0, RSTART, RLENGTH))
              if (!(mac in keep)) { dropped[mac]++; next }
            }
            print
          }
          END {
            for (m in dropped) list = list (list ? ", " : "") m " (" dropped[m] ")"
            if (list) print "wireplumber: " file ": pruned " list > "/dev/stderr"
          }
        ' "$state/$f" > "$tmp"

        if [ "$dry" -eq 1 ]; then
          ${pkgs.diffutils}/bin/diff -u "$state/$f" "$tmp" || true
          rm -f "$tmp"
        else
          ${pkgs.diffutils}/bin/cmp -s "$tmp" "$state/$f" || cat "$tmp" > "$state/$f"
          rm -f "$tmp"
        fi
      done

      [ "$restart" -eq 1 ] && ${pkgs.systemd}/bin/systemctl --user start wireplumber
      exit 0
    '';
  in {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

    environment.systemPackages = [ wireplumberPruneState ];

    # Headsets expose two profiles with two independently stored volumes
    # (a2dp `headset-output` vs hfp `headset-hf-output`). WirePlumber's
    # autoswitch flips between them whenever anything opens a mic, so the
    # volume percentage jumps and playback collapses to HFP mono. Keep
    # headsets in A2DP and hide their mic; the rnnoise chain then follows
    # whatever real input is default. To use a headset mic on purpose,
    # select its `headset-head-unit` profile by hand.
    services.pipewire.wireplumber.extraConfig."51-bluetooth-no-autoswitch" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
        # Stops "was in headset mode" being restored over your choice on
        # every reconnect -- the reason settings appear to revert by themselves.
        "bluetooth.use-persistent-storage" = false;
        "bluetooth.profile-preference" = "quality";
      };
    };
  };
}
