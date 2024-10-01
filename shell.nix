let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  inherit (pkgs) lib;
b' = lib.meta.getExe;
  noogle = rec {
    src = sources.noogle;
    # offline instance of migrate-doc-comments ?? am I crazy?
    # https://github.com/hsjobeki/nixpkgs/blob/master/.github/workflows/update-comments.yml
    build-script = pkgs.writeShellScriptBin "noogle-build" ''
      ${nix} build ${sources.noogle}#ui -o result/noogle
    '';
    run-script = pkgs.writeShellScriptBin "noogle-run" ''
      ${b' build-script}
      ${b' pkgs.httplz} -q -x ./result/noogle/lib/node_modules/noogle/out
    '';
  };
  mmdocs = { }; # todo get that github pr?
  multipageofficial = { }; # https://github.com/NixOS/nixpkgs/compare/nixos-24.05...GetPsyched:nixpkgs:render-docs?w=1
  nixpkgs-tracker = { }; # nixpkgs tracker
  nixpkgs-pr-tracker = { }; # pr-tracker
  nix = ''${b' pkgs.nix} --extra-experimental-features "nix-command flakes"'';
  # TODO tmuxp for w3m
  docs-browse =
    browser:
    pkgs.writeShellScriptBin "docs-browse" ''
      ${b' docs-build}
      ${browser} ./result/nix-latest-doc/share/doc/nix/manual/index.html
      ${browser} ./result/nixpkgs-git-manual/share/doc/nixpkgs/manual.html
      ${browser} ./result/nixos-git-manual/share/doc/nixos/index.html
    '';
  docs-build = pkgs.writeShellScriptBin "docs-build" ''
    ${nix} build ${sources.nix}#nix^doc --print-out-paths -o result/nix-latest-doc
    ${nix} build ${sources.nixpkgs}#nixpkgs-manual --print-out-paths -o result/nixpkgs-git-manual
    ${pkgs.nix}/bin/nix-build ${sources.nixpkgs}/nixos/release.nix -A manualHTML.x86_64-linux -o result/nixos-git-manual
  '';
  scripts = [
    docs-build
    (docs-browse (b' pkgs.w3m)) # pkgs.qutebrowser
    noogle.build-script
    noogle.run-script
  ];
in
pkgs.mkShellNoCC {
  packages =
    with pkgs;
    [
      black
      (python312.withPackages (pypkgs: with pypkgs; [ beautifulsoup4 ]))

      npins
      nixfmt-rfc-style
      deadnix
      statix
    ]
    ++ scripts;
}
