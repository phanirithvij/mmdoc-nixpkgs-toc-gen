{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nix.url = "github:nixos/nix/latest-release";
    nix.inputs.nixpkgs.follows = "nixpkgs";
    nix.inputs.flake-compat.follows = "";
    #nix.url = "github:nixos/nix/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    #home-manager.url = "github:nix-community/home-manager/release-25.11";
    noogle.url = "github:nix-community/noogle/main";
    noogle.inputs.nix-master.follows = "nix";
    noogle.inputs.nixpkgs-master.follows = "nixpkgs";
    noogle.inputs.nixpkgs.follows = "nixpkgs";
    noogle.inputs.pre-commit-hooks.follows = "";
  };

  outputs =
    inputs:
    let
      forAllSystems = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
      defaultNix = system: (import ./. { inherit system; });
    in
    {
      devShell = forAllSystems (system: (defaultNix system).shell);
    };
}
