{ self, ... }: {
  flake.nixosModules.vesktop = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.vesktop ];
  };

  # Chromium's WebRTC enumerates every interface when gathering ICE candidates and
  # picks up tailscale0 (100.x / fd7a:), which leaves voice and screenshare dead
  # after ICE completes (packetsSent stays 0) whenever Tailscale is up. Pinning the
  # IP handling policy to the default route keeps the tailnet addresses out of the
  # candidate set. Tailscale-side knobs (--netfilter-mode, --accept-dns) do nothing.
  # https://github.com/tailscale/tailscale/issues/20450
  # https://github.com/Vencord/Vesktop/issues/876
  flake.homeModules.vesktop = { config, pkgs, lib, ... }:
  let
    settingsFile = "${config.xdg.configHome}/vesktop/settings.json";
    policy = "default_public_and_private_interfaces";
  in {
    # Vesktop rewrites settings.json itself, so this can't be a home.file symlink —
    # merge our key in and leave the rest of the file (and its writability) alone.
    home.activation.vesktopWebRTCPolicy = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$(dirname "${settingsFile}")"
      if [ ! -s "${settingsFile}" ]; then
          echo '{}' > "${settingsFile}"
      fi

      if ${pkgs.jq}/bin/jq -e '.webRTCIPHandlingPolicy == "${policy}"' "${settingsFile}" > /dev/null; then
          :
      else
          echo "Setting Vesktop webRTCIPHandlingPolicy to ${policy}"
          ${pkgs.jq}/bin/jq '.webRTCIPHandlingPolicy = "${policy}"' "${settingsFile}" > "${settingsFile}.new"
          mv -f "${settingsFile}.new" "${settingsFile}"
      fi
    '';
  };
}
