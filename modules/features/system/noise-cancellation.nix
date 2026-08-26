{ ... }: {
  flake.nixosModules.noise-cancellation = { pkgs, ... }: {
    services.pipewire.extraLadspaPackages = [ pkgs.rnnoise-plugin.ladspa ];

    services.pipewire.extraConfig.pipewire."99-noise-cancellation" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          # Without nofail, a rnnoise plugin that fails to load takes the whole
          # PipeWire daemon down with it -- no audio at all, rather than just no
          # noise cancelling. Upstream's own source-rnnoise.conf sets this too.
          flags = [ "nofail" ];
          args = {
            "node.description" = "Noise Canceling source";
            "media.name"       = "Noise Canceling source";

            "filter.graph" = {
              nodes = [
                {
                  type    = "ladspa";
                  name    = "rnnoise";
                  plugin  = "librnnoise_ladspa";
                  label   = "noise_suppressor_mono";
                  control = {
                    "VAD Threshold (%)"          = 35.0;
                    "VAD Grace Period (ms)"       = 200;
                    "Retroactive VAD Grace (ms)"  = 0;
                  };
                }
                # rnnoise is mono, but apps (vesktop) negotiate stereo capture
                # and leave the right port unlinked -> silent channel. Fan the
                # single output out with the builtin copy filter, which is what
                # the filter-chain docs recommend for routing one signal to
                # several outputs.
                { type = "builtin"; name = "copyFL"; label = "copy"; }
                { type = "builtin"; name = "copyFR"; label = "copy"; }
              ];
              links = [
                { output = "rnnoise:Output"; input = "copyFL:In"; }
                { output = "rnnoise:Output"; input = "copyFR:In"; }
              ];
              inputs  = [ "rnnoise:Input" ];
              outputs = [ "copyFL:Out" "copyFR:Out" ];
            };

            "capture.props" = {
              "node.name"      = "capture.rnnoise_source";
              "node.passive"   = true;
              "audio.rate"     = 48000;
              "audio.channels" = 1;
              "audio.position" = [ "MONO" ];
            };

            "playback.props" = {
              "node.name"        = "rnnoise_source";
              "node.description" = "Noise Canceling source";
              "media.class"      = "Audio/Source";
              "audio.rate"       = 48000;
              "audio.channels"   = 2;
              "audio.position"   = [ "FL" "FR" ];
              "priority.session" = 2000;
            };
          };
        }
      ];
    };
  };
}
