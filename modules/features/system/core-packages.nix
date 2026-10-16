{self, ...}: {
  flake.nixosModules.core-packages = {pkgs, ...}:
  let
    # Spotify's CEF build draws its content shrunk when a monitor's scale is
    # below 1 on native Wayland, and ignores Chromium's fractional-scale flags.
    # Under XWayland Hyprland does the scaling, so the window fills correctly.
    spotify = pkgs.symlinkJoin {
      name = "spotify";
      paths = [ pkgs.spotify ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/spotify --unset NIXOS_OZONE_WL --add-flags "--ozone-platform=x11"
      '';
    };
  in {
    environment.systemPackages = with pkgs; [
      # --- System Utilities ---
      fastfetch
      wget
      zip
      unzip
      dbus
      jq
      bc
      vlc

      # --- Screen Capture & OCR ---
      slurp
      grim
      satty
      imagemagick # (Provides magick)
      wl-clipboard # (Provides wl-copy)
      tesseract
      xdg-utils # (Provides xdg-open for Google Lens)
      wf-recorder # (For Screen Recording)

      gdu # Disk usage analyzer
      fd # Faster 'find'
      ripgrep # Faster 'grep'
      tldr # Simpler 'man' pages

      # --- Connectivity ---
      dmenu
      networkmanager_dmenu
      networkmanagerapplet
      bluez
      bluez-tools

      # --- Document Handling ---
      pandoc
      poppler-utils
      texliveSmall
      # ocrmypdf
      libreoffice-stable

      # --- Media / Visuals ---
      playerctl
      brightnessctl

      # --- Nix Tools ---
      nh
      nix-output-monitor
      nix-tree

      # --- Monitoring ---
      btop

      # --- Sound ---
      crosspipe

      # --- Extras ---
      spotify
    ];
  };
}
