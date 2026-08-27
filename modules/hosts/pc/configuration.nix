{ self, inputs, ... }: {
  flake.nixosModules.pc-configuration = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.pc-hardware
    ];

    networking.hostName = "pc";
    system.stateVersion = "25.05";

    # NVIDIA
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = true;
    };

    boot.kernelModules = ["nvidia_uvm"];

    # Graphics stack
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [pkgs.nvidia-vaapi-driver];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";
      # nvidia-vaapi-driver runs in Firefox's RDD process; the decoder
      # can't reach the GPU with the sandbox on
      MOZ_DISABLE_RDD_SANDBOX = "1";
    };

    # GPU monitoring in btop needs the CUDA build; hiPrio wins over the
    # plain btop from core-packages
    environment.systemPackages = [
      (lib.hiPrio (pkgs.btop.override {cudaSupport = true;}))
    ];

    boot.kernelParams = [
      "usbcore.autosuspend=-1"
      # btusb is built with CONFIG_BT_HCIBTUSB_AUTOSUSPEND=y and calls
      # usb_enable_autosuspend() on its own device at probe, which overrides
      # usbcore.autosuspend=-1 for the BT radio specifically. A failed runtime
      # suspend ("Failed to suspend device, error -110") wedged the MT7922
      # Bluetooth (0e8d:0616, usb 1-12) on 2026-05-30; it stayed dead across
      # every subsequent boot because the M.2 slot keeps +5VSB in S5, so only
      # a standby-power cycle clears it.
      "btusb.enable_autosuspend=0"
      "nvidia-drm.fbdev=1"
    ];

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;
      theme = "${inputs.grubermeister.packages.${pkgs.stdenv.hostPlatform.system}.default}";

      entryOptions    = "--unrestricted --class nixos";
      subEntryOptions = "--unrestricted --class nixos-generation";
    };
  };
}
