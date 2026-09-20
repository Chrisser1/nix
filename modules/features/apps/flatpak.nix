{ self, ... }: {
  flake.nixosModules.flatpak = { pkgs, ... }: {
    # Requires xdg.portal.enable, which the hyprland module already sets.
    services.flatpak.enable = true;

    # The nixpkgs module has no declarative remotes, so add flathub once at boot.
    # Flatseal (the sandbox permission editor) is not packaged in nixpkgs — it only
    # ships as a flatpak, so pull it from flathub here rather than systemPackages.
    systemd.services.flatpak-repo = {
      description = "Add the flathub remote and install Flatseal";
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
        flatpak install --noninteractive --assumeyes flathub com.github.tchx84.Flatseal
      '';
    };
  };
}
