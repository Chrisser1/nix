{self, ...}: {
  flake.homeModules.appearance = {pkgs, ...}: {
    # MIME App Defaults
    xdg.mimeApps.defaultApplications."x-scheme-handler/jetbrains" = "jetbrains-toolbox.desktop";

    # Dark mode hints for apps that read settings.ini directly.
    # color-scheme and gtk-theme are intentionally omitted here — noctalia owns those
    # and sets them via gsettings when you switch themes.
    gtk = {
      enable = true;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    # Qt theming via qt6ct/qt5ct — select the noctalia color scheme in qt6ct after first run
    qt = {
      enable = true;
      platformTheme.name = "qtct";
    };

    home.packages = with pkgs; [
      adw-gtk3
      kdePackages.qt6ct
      libsForQt5.qt5ct
    ];
  };
}
