{
  description = "asta system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.asta = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
