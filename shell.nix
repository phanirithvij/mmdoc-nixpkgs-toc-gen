let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  nix = import sources.nix { };
  mmdocs = { }; # todo get that github pr?
  noogle = { }; # figure out pagefind
  multipageofficial = { }; # https://github.com/NixOS/nixpkgs/compare/nixos-24.05...GetPsyched:nixpkgs:render-docs?w=1
  nixpkgs-tracker = { }; # nixpkgs tracker
  nixpkgs-pr-tracker = { }; # pr-tracker
  qutebrowser = { }; # w3m alternative
  w3m = pkgs.w3m;
  browser = w3m;
  nix-docs = pkgs.writeShellScript "nix-docs" ''
    w3m $(nix build github:nixos/nixpkgs/nixos-unstable#nixpkgs-manual --print-out-paths)/share/doc/nixpkgs/manual.html
    w3m $(nix-build nixos/release.nix -A manualHTML.x86_64-linux)/share/doc/nixos/index.html
    w3m $(nix build github:nixos/nix#nix^doc --print-out-paths)/share/doc/nix/manual/index.html
  '';
in
pkgs.mkShellNoCC {
  packages = with pkgs; [
    black
    (python312.withPackages (pypkgs: with pypkgs; [ beautifulsoup4 ]))

    npins
    nixfmt-rfc-style
    deadnix
    statix
  ];
}
