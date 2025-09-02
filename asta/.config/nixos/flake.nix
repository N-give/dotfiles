{
  description = "asta system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-ld, sops-nix }: {
    nixosConfigurations.asta = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ 
        nix-ld.nixosModules.nix-ld
        ./configuration.nix 
        sops-nix.nixosModules.sops
      ];
    };
  };
}
