# Shared NixOS config. Disk layout and CPU firmware come from
# /etc/nixos/hardware-configuration.nix on each machine. Anything that
# should not follow this repo goes in /etc/nixos/local.nix.
{ pkgs, lib, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./edge-apps.nix
    ./homebrew-path.nix
  ]
  ++ lib.optional (builtins.pathExists /etc/nixos/local.nix) /etc/nixos/local.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/La_Paz";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_BO.UTF-8";
    LC_IDENTIFICATION = "es_BO.UTF-8";
    LC_MEASUREMENT = "es_BO.UTF-8";
    LC_MONETARY = "es_BO.UTF-8";
    LC_NAME = "es_BO.UTF-8";
    LC_NUMERIC = "es_BO.UTF-8";
    LC_PAPER = "es_BO.UTF-8";
    LC_TELEPHONE = "es_BO.UTF-8";
    LC_TIME = "es_BO.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "latam";
  services.libinput.enable = true;
  console.keyMap = "la-latin1";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Plasma only shows Bluetooth settings when this is on.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.graphics.enable = true;

  services.fwupd.enable = true;

  # Model server for a remote OpenCode machine. CPU build.
  # Listens on every interface, but the firewall allows port 11434
  # only from the Tailscale network. Ollama has no login of its own.
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 11434 ];

  # Remote login as timoteo. Root password login stays off.
  # The NixOS module opens port 22. Password login is the module default.
  services.openssh.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };

  # The key stays in this file on the machine. It is not copied into the
  # Nix store. A reusable, pre-approved key from the Tailscale admin page,
  # one line, mode 600. Once the node is Running, the daemon reconnects
  # by itself; this timer only calls `tailscale up` when it is logged out.
  systemd.services.tailscale-ensure-up = {
    description = "Log Tailscale in when the node is down";
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [
      "tailscaled.service"
      "network-online.target"
    ];
    path = [
      pkgs.tailscale
      pkgs.jq
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      keyfile=/etc/nixos/tailscale-authkey
      state="$(tailscale status --json --peers=false 2>/dev/null | jq -r '.BackendState // empty' || true)"
      case "$state" in
        Running)
          exit 0
          ;;
        NeedsLogin|NeedsMachineAuth|Stopped)
          if [ ! -f "$keyfile" ]; then
            echo "Tailscale is $state. Add a reusable auth key as the only line of $keyfile."
            exit 0
          fi
          tailscale up --timeout 30s --auth-key "$(tr -d '\n' < "$keyfile")"
          ;;
      esac
    '';
  };
  systemd.timers.tailscale-ensure-up = {
    description = "Check Tailscale while it is logged out";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20s";
      OnUnitInactiveSec = "1min";
    };
  };

  # `docker` is Podman. `docker compose` calls pkgs.docker-compose (Compose v2).
  # Unqualified image names search Docker Hub.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
    extraPackages = [ pkgs.docker-compose ];
  };
  virtualisation.containers.registries.search = [ "docker.io" ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;
  programs.fish.enable = true;
  # Homebrew bottles and other prebuilt binaries need a dynamic linker.
  programs.nix-ld.enable = true;

  users.users.timoteo = {
    isNormalUser = true;
    description = "Timoteo Ponce";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
      brave
      microsoft-edge
      libreoffice-qt
      spotify
      transmission_4-qt
      ghostty
      alacritty
      zed-editor
      vscode
      pcloud
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    nano
    btop
    git
    curl
    docker-compose
  ];

  # Re-applied on each rebuild. Edit nixos/powerdevilrc, then switch again.
  systemd.tmpfiles.rules = [
    "d /home/timoteo/.config 0755 timoteo users - -"
    "C+ /home/timoteo/.config/powerdevilrc 0644 timoteo users - ${./powerdevilrc}"
  ];

  system.stateVersion = "26.05";
}
