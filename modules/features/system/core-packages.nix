{self, ...}: {
  flake.nixosModules.core-packages = {pkgs, ...}: {
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
      libreoffice-fresh

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
