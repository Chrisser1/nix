{ self, ... }: {
  flake.homeModules.work-comms = { config, pkgs, ... }: {
    home.packages = [ pkgs.teams-for-linux ];

    xdg.desktopEntries.outlook = {
      name = "Outlook";
      genericName = "Email client";
      comment = "Outlook web app in its own window";
      icon = "mail-client";
      categories = [ "Network" "Email" ];
      exec = ''${pkgs.ungoogled-chromium}/bin/chromium --app=https://outlook.office.com/mail/ --class=Outlook --user-data-dir=${config.home.homeDirectory}/.local/share/outlook-pwa'';
      terminal = false;
    };
  };
}
