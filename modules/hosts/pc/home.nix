{self, ...}: {
  flake.homeModules.pc-home = {
    config,
    pkgs,
    inputs,
    ...
  }: {
    home.stateVersion = "25.05";

    # Hardware video decode (NVDEC) via nvidia-vaapi-driver.
    # Only works in Firefox — Chromium/Electron can't use this driver.
    # Needs MOZ_DISABLE_RDD_SANDBOX=1, set in pc-configuration.
    programs.firefox.profiles.chris.settings = {
      "media.hardware-video-decoding.force-enabled" = true; # Firefox 137+
      "media.ffmpeg.vaapi.enabled" = true; # pre-137 fallback, harmless now
      "media.rdd-ffmpeg.enabled" = true;
    };

    wayland.windowManager.hyprland.settings = {
      monitor = [
        # Middle monitor (ASUS)
        # "DP-1,highrr,0x0,1"
        "DP-4,highrr,0x0,1"

        # Left monitor (HP)
        "HDMI-A-2,1920x1080,auto-left,1"

        ## Right monitor (HP)
        # "HDMI-A-2,highrr,auto-left,1"
      ];
    };
  };
}
