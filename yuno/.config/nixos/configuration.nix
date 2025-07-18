# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "yuno"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.firewall.allowedTCPPortRanges = [
    { from = 3000; to = 60000; }
  ];
  networking.firewall.allowedTCPPorts = [ 22 80 443 631 ];
  networking.firewall.allowedUDPPorts = [ 631 config.services.tailscale.port ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Indiana/Indianapolis";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  hardware.keyboard.zsa.enable = true;

  hardware.graphics.enable = true;

  # nvidia
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/var/lib";
    XDG_CACHE_HOME = "$HOME/var/cache";
    NIXOS_OZONE_WL = "1";
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable hyprland window manager
  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

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

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  fonts = {
    packages = with pkgs; [
      # nerdfonts
      nerd-fonts.fira-code
      # nerd-fonts.fira-code-symbols
      powerline-fonts
      monoid
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "FreeSerif" ];
        sansSerif = [ "FreeSans" ];
        monospace = [ "Monoid" ];
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nate = {
    isNormalUser = true;
    description = "Nate Givens";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    packages = with pkgs; [
      acpi
      alacritty
      audacity
      autorandr
      bat
      bluez
      bottom
      brightnessctl
      cachix
      certbot
      direnv
      dunst
      du-dust
      emacs
      eza
      exercism
      exfat
      fd
      feh
      firefox
      ffmpeg-full
      frei0r
      fzf
      gcc
      ghostty
      git
      gitAndTools.delta
      google-chrome
      glxinfo
      graphviz
      hicolor-icon-theme
      hypridle
      hyprlock
      hyprpaper
      imagemagick
      kdePackages.kdenlive
      kind
      lsof
      lxappearance
      mediainfo
      mkcert
      navi
      neovim
      nload
      nmap
      nushell
      openssl
      pavucontrol
      pciutils
      procs
      pueue
      ripgrep
      rlwrap
      sd
      skim
      starship
      stow
      spaceFM
      tailscale
      tmux
      unzip
      vlc
      wally-cli
      waybar
      wezterm
      write_stylus
      xorg.xwininfo
      zathura
      zellij
      zip
      zoxide
      zsa-udev-rules
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    git
    kitty
    lshw
    neovim
    monoid
    wofi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
