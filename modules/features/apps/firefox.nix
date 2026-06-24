{ self, inputs, ... }: {
  
  flake.homeModules.firefox = { pkgs, lib, config, ... }: 
  let
    addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    programs.firefox = {
      enable = true;

      configPath = ".mozilla/firefox";
      
      policies = {
        DisableTelemetry = true;
        DisableFirefoxAccounts = true;
        DisablePocket = true;
        DisplayMenuBar = "never";
        DontCheckDefaultBrowser = true;
        DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
        
        ExtensionSettings = {
          "{f3b4b962-34b4-4935-9eee-45b0bce58279}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/animated-purple-moon-lake/latest.xpi";
            installation_mode = "force_installed";
          };
        };

        # We handle extension settings here, but install the actual code in the profile
        "3rdparty".Extensions = {
          "uBlock0@raymondhill.net".adminSettings = {
            userSettings = rec {
              uiTheme = "dark";
              uiAccentCustom = true;
              uiAccentCustom0 = "#8300ff";
              cloudStorageEnabled = lib.mkForce false;
              importedLists = [
                "https://filters.adtidy.org/extension/ublock/filters/3.txt"
                "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
              ];
              externalLists = lib.concatStringsSep "\n" importedLists;
            };
          };
        };
      };

      profiles.chris = {
        isDefault = true;
        extensions.packages = [
          addons.ublock-origin
          addons.bitwarden
        ];

        settings = {
          "extensions.autoDisableScopes" = 0;

          "extensions.activeThemeID" = "{f3b4b962-34b4-4935-9eee-45b0bce58279}";

          "browser.uiCustomization.state" = builtins.toJSON {
            placements = {
              nav-bar = [
                "back-button" "forward-button" "stop-reload-button" 
                "urlbar-container" "downloads-button" 
                "ublock0_raymondhill_net-browser-action" 
                "bitwarden_josefnw-browser-action"
              ];
            };
          };

          # General hardening from your original list
          "signon.rememberSignons" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "datareporting.healthreport.uploadEnabled" = false;
        };

        search = {
          force = true;
          default = "google";
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "channel"; value = "unstable"; }
                  { name = "query";   value = "{searchTerms}"; }
                ];
              }];
              icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "Nix Options" = {
              urls = [{
                template = "https://search.nixos.org/options";
                params = [
                  { name = "channel"; value = "unstable"; }
                  { name = "query";   value = "{searchTerms}"; }
                ];
              }];
              icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };

            "NixOS Wiki" = {
              urls = [{
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  { name = "search"; value = "{searchTerms}"; }
                ];
              }];
              icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nw" ];
            };
          };
        };
      };
    };
  };
}