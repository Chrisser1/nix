{ self, ... }: {
  flake.homeModules.work-comms = { config, pkgs, ... }:
  let
    # Copy just the one icon so the 250M Papirus theme stays out of the closure.
    outlookIcon = pkgs.runCommand "outlook-icon.svg" { } ''
      cp ${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/ms-outlook.svg $out
    '';
  in {
    home.packages = [ pkgs.teams-for-linux ];

    xdg.desktopEntries.outlook = {
      name = "Outlook";
      genericName = "Email client";
      comment = "Outlook web app in its own window";
      icon = "${outlookIcon}";
      categories = [ "Network" "Email" ];
      exec = ''${pkgs.ungoogled-chromium}/bin/chromium --app=https://outlook.office.com/mail/ --user-data-dir=${config.home.homeDirectory}/.local/share/outlook-pwa'';
      terminal = false;
      settings.StartupWMClass = "chrome-outlook.office.com__mail_-Default";
    };
  };
}
