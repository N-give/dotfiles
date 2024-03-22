# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

  kubeMasterIP = "127.0.0.1";
  # kubeMasterIP = "10.1.1.2";
  kubeMasterHostname = "localhost";
  # kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
      # <home-manager/nixos>
      # /home/nate/.config/nixpkgs/config.nix
    ];

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Allow unfree
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    useOSProber = true;
    configurationLimit = 2;
    fontSize = 24;
  };
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  networking.hostName = "yuno"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.firewall.allowedTCPPortRanges = [
    { from = 3000; to = 60000; }
  ];
  networking.firewall.allowedTCPPorts = [ 22 80 443 631 ];
  networking.firewall.allowedUDPPorts = [ 631 config.services.tailscale.port ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.networkmanager.enable = true;

  # networking.wg-quick.interfaces = {
  #   wg0 = {
  #     address = [ "10.6.0.3/24" ];
  #     # privateKey = "UMtHzrBLx91XiPwzHnb0XYMPOIRg8wp81b6RUwbXA3w=";
  #     privateKeyFile = "/root/wireguard-keys/privatekey";
  #     dns = [ "9.9.9.9" "149.112.112.112" ];
  #     peers = [
  #       {
  #         publicKey = "8qGTY4Sov5/8c6kFkdbMvrukzWqz48Xwm5kBWhFLcQM=";
  #         presharedKey = "KgveBNq/FzlkbwDQeqTAI8wPFNJMMHaP1QnDQeC39GE=";
  #         allowedIPs = [ "0.0.0.0/0" "::0/0" ];
  #         endpoint = "mysonic.homenode.ca:51820";
  #         persistentKeepalive = 25;
  #       }
  #     ];
  #     # extraConfig = ''
  #     #   [Interface]
  #     #   PrivateKey = UMtHzrBLx9lXiPwzHnb0XYMPOIRg8wp81b6RUwbXA3w=
  #     #   Address = 10.6.0.3/24
  #     #   DNS = 9.9.9.9, 149.112.112.112

  #     #   [Peer]
  #     #   PublicKey = 8qGTY4Sov5/8c6kFkdbMvrukzWqz48Xwm5kBWhFLcQM=
  #     #   PresharedKey = KgveBNq/FzlkbwDQeqTAI8wPFNJMMHaP1QnDQeC39GE=
  #     #   Endpoint = mysonic.homenode.ca:51820
  #     #   AllowedIPs = 0.0.0.0/0, ::0/0
  #     # '';
  #   };
  # };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens4u1u2.useDHCP = true;
  networking.interfaces.wlp59s0.useDHCP = true;

  # networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus32";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/Indianapolis";


  # environment.etc = {
  #   "wireplumber/bluetooth.lua.d/51-bluez-corfig.lua".text = ''
  #     bluez_monitor.properties = {
  #       ["bluez5.enable-sbc-xq"] = true,
  #       ["bluez5.enable-msbc"] = true,
  #       ["bluez5.enable-hw-volume"] = true,
  #       ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
  #     }
  #   '';
  # };

  hardware.keyboard.zsa.enable = true;

  services.tailscale.enable = true;
    systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey tskey-auth-kRsNEp5CNTRL-e7LsTWm2TeX3XudBywCbdXnNB46FdzFc
    '';
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    breeze-gtk
    breeze-icons
    clusterctl
    cmctl
    dmenu
    # gimp-with-plugins
    kubernetes-helm
    kompose
    kubectl
    kubernetes
    neovim
    networkmanager-l2tp
    parted
    psmisc
    rawtherapee
    wget
    nvidia-offload
    stow
    usbutils
    # wireguard
    # wireguard-tools
  ];

  gtk.iconCache.enable = true;

  fonts = {
    packages = with pkgs; [
      # nerdfonts
      powerline-fonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "FreeSerif" ];
        sansSerif = [ "FreeSans" ];
        monospace = [ "Monoid" ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.fwupd.enable = true;
  services.upower.enable = true;

  # Enable printing
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;
  # for an USB printer
  services.ipp-usb.enable = true;
  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*.631" ];
  services.printing.allowFrom = [ "all" ];
  services.printing.defaultShared = true;

  # accelerated video playback

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for firefox/chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # enable docker
  virtualisation.docker.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = false;
    # extraModules = [ pkgs.pulseaudio-modules-bt ];
    # package = pkgs.pulseaudioFull;
    # extraConfig = "
    #   load-module module-bluetooth-discover
    #   load-module module-switch-on-connect
    # ";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # High quality BT calls
    # media-session.config.bluez-monitor.rules = [
    #   {
    #     matches = [{ "device.name" = "~bluez_card.*"; }];
    #     actions = {
    #       "update-props" = {
    #         "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
    #         # "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
    #         "bluez5.msbc-support" = true;
    #         "bluez5.sbc-xq-support" = true;
    #       };
    #     };
    #   }
    #   {
    #     matches = [
    #       # matches all sources
    #       { "node.name" = "~bluez_input.*"; }
    #       # Matches all outputs
    #       { "node.name" = "~bluez_output.*"; }
    #     ];
    #     actions = {
    #       "node.pause-on-idle" = false;
    #     };
    #   }
    # ];
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.hsphfpd.enable = false;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  services.blueman.enable = true;


  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    offload.enable = true;

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Enable touchpad support.
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      tapping = false;
      middleEmulation = true;
    };
  };

  # trace: warning: The option `services.xserver.libinput.tapping' defined in `/etc/nixos/configuration.nix' has been renamed to `services.xserver.libinput.touchpad.tapping'.
  # trace: warning: The option `services.xserver.libinput.middleEmulation' defined in `/etc/nixos/configuration.nix' has been renamed to `services.xserver.libinput.touchpad.middleEmulation'.

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  services.xserver = {
    layout = "us";
    # xkbOptions = "grp:alts_toggle";
    enable = true;
    # displayManager.sddm.enable = true;
    # desktopManager = {
    #   xterm.enable = false;
    #   plasma5.enable=true;
    # };
    displayManager = {
      defaultSession = "none+xmonad";
      lightdm = {
        greeters.gtk.theme.name = "Breeze-Dark";
        greeters.gtk.cursorTheme.name = "Breeze-Dark";
        greeters.gtk.iconTheme.name = "Breeze-Dark";
        greeters.gtk.cursorTheme.size = 24;
      };
    };
    # windowManager.i3 = {
    #   enable = true;
    #   extraPackages = with pkgs; [
    #     polybar
    #     i3lock
    #   ];
    # };
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      # extraPackages = haskellPackages: with haskellPackages; [
      #   taffybar
      # ];
    };
  };

  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  # services.kubernetes = {
  #   roles = ["master" "node"];
  #   masterAddress = kubeMasterHostname;
  #   apiserverAddress =
  #     "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
  #   easyCerts = true;
  #   apiserver = {
  #     securePort = kubeMasterAPIServerPort;
  #     advertiseAddress = kubeMasterIP;
  #   };
  #   # scheduler.enable = true;
  #   # addonManager.enable = true;
  #   addons.dns.enable = true;
  #   # proxy.enable = true;
  #   # flannel.enable = true;
  #   kubelet.extraOpts = "--fail-swap-on=false";
  # };

  services.dockerRegistry.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users.nate = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
  };
  # home-manager.users.nate = (import /home/nate/.config/nixpkgs/home.nix);

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

