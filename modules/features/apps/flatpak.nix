{ self, ... }: {
  flake.nixosModules.flatpak = { pkgs, ... }: {
    # Requires xdg.portal.enable, which the hyprland module already sets.
    services.flatpak.enable = true;

    # Flatseal for editing per-app sandbox permissions.
    environment.systemPackages = [ pkgs.flatseal ];

    # The nixpkgs module has no declarative remotes, so add flathub once at boot.
    systemd.services.flatpak-repo = {
      description = "Add the flathub remote";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
