{
  description = "Shared NixOS configuration. Hardware comes from /etc/nixos on each machine.";

  # Pinned to the revision this machine was installed with.
  # Bump with: nix flake update nixpkgs
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/6fcc160353f63555b560f25588925133c8f61f2a";

  outputs =
    { nixpkgs, ... }:
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./nixos/configuration.nix ];
      };
    };
}
