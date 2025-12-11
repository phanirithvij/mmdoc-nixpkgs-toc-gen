# Copied from ngipkgs licensed MIT Copyright (c) 2025 NGI nix contributors.
let
  flake-inputs = import (fetchTarball {
    url = "https://github.com/phanirithvij/flake-inputs/tarball/file-type"; # TODO tag
    sha256 = "sha256-4d2u5m8TOQMSt1uKlQiJ3zZgykQ+FiXn8VtyYaiAQfM=";
  });
  inherit (flake-inputs) import-flake;
in
{
  flake ? import-flake { src = ./.; },
  sources ? flake.inputs,
  #sources ? import ./npins,
  nixpkgs ? sources.nixpkgs,
  system ? builtins.currentSystem,
  config ? { },
  overlays ? [ ],
  pkgs ? import nixpkgs {
    inherit system config overlays;
  },
  lib ? pkgs.lib,
}:
let
  stripStorePrefix = import ./nix/lib/strip-store-prefix.nix lib;
  b' = lib.meta.getExe;
  noogle = {
    # offline instance of migrate-doc-comments ?? am I crazy?
    # https://github.com/hsjobeki/nixpkgs/blob/master/.github/workflows/update-comments.yml
    # pagefind is part of the build
    build = pkgs.writeShellScriptBin "noogle-build" ''
      ${fnix} build ${sources.noogle}#ui -o result/noogle
    '';
    run = pkgs.writeShellScriptBin "noogle-run" ''
      ${b' noogle.build}
      pushd ./result/noogle 2>&1 >/dev/null
      ${b' pkgs.miniserve} --spa --index index.html -p 8001
      popd 2>&1 >/dev/null
    '';
  };
  nixos-search = { }; # does it work without elasticsearch?
  home-manager-options-search = { }; # see hm docs .nix.docs.json
  qutebrowser = {
    pkg = pkgs.qutebrowser;
    config = pkgs.writeText "docs-qute-conf.py" ''
      config.load_autoconfig()
      config.set("colors.webpage.darkmode.enabled", True)
    '';
  };
  mmdocs = { }; # todo get that github pr?
  multipage-official = { }; # https://github.com/NixOS/nixpkgs/compare/nixos-24.05...GetPsyched:nixpkgs:render-docs?w=1
  nixpkgs-tracker = { }; # nixpkgs tracker
  nixpkgs-pr-tracker = { }; # pr-tracker
  #fnix = ''${b' pkgs.nix} --extra-experimental-features "nix-command flakes"'';
  fnix = "${b' pkgs.nix-output-monitor}";
  docs = {
    # TODO stable and unstable manuals
    # TODO use these instead of build commands etc.
    hm-docs = (import sources.home-manager { inherit pkgs; }).docs.html;
    nix-docs = (import sources.nix).packages.${system}.nix-manual;
    nixpkgs-docs = pkgs.nixpkgs-manual;
    nixos-docs = ((import "${sources.nixpkgs}/nixos/release.nix") { }).manualHTML.${system};
    tmuxp-workspace = pkgs.writeText "docs-tmuxp-w3m.yaml" ''
      session_name: 'nix-docs'
      windows:
      - panes:
        - ${b' pkgs.w3m} ${docs.nix.dest}; exec $SHELL
        window_name: nix-latest-doc
        suppress_history: false
        window_shell: /bin/sh
      - panes:
        - ${b' pkgs.w3m} ${docs.nixpkgs.dest}; exec $SHELL
        window_name: nixpkgs-unstable-manual
        suppress_history: false
        window_shell: /bin/sh
      - panes:
        - ${b' pkgs.w3m} ${docs.nixos.dest}; exec $SHELL
        window_name: nixos-unstable-manual
        suppress_history: false
        window_shell: /bin/sh
      - panes:
        - ${b' pkgs.w3m} ${docs.hm.dest}; exec $SHELL
        window_name: hm-unstable-manual
        suppress_history: false
        window_shell: /bin/sh
    '';
    browse = {
      qute = pkgs.writeShellScriptBin "docs-browse-qute" ''
        ${b' docs.build}
        configfile=~/.config/qutebrowser/config.py
        if [ ! -f "$configfile" ]; then
          configfile=${qutebrowser.config}
        fi
        ${b' qutebrowser.pkg} --config-py "$configfile" \
          ${docs.nix.dest} \
          ${docs.nixpkgs.dest} \
          ${docs.nixos.dest} \
          ${docs.hm.dest} \
          http://localhost:8001
      '';
      tmux = pkgs.writeShellScriptBin "docs-browse-tmux" ''
        ${b' docs.build}
        ${b' pkgs.tmuxp} load -y ${docs.tmuxp-workspace}
      '';
    };
    build = pkgs.writeShellScriptBin "docs-build" ''
      ${docs.nix.cmd}
      ${docs.nixpkgs.cmd}
      ${docs.nixos.cmd}
      ${docs.hm.cmd}
    '';
    nix = rec {
      cmd = "${fnix} build ${sources.nix}#packages.${system}.nix-manual --print-out-paths -o ${out}";
      out = "./result/nix-latest";
      dest = "${out}/share/doc/nix/manual/index.html";
    };
    nixpkgs = rec {
      cmd = "${fnix} build ${sources.nixpkgs}#nixpkgs-manual --print-out-paths -o ${out}";
      out = "./result/nixpkgs-git-manual";
      dest = "${out}/share/doc/nixpkgs/manual.html";
    };
    nixos = rec {
      cmd = "${pkgs.nix}/bin/nix-build ${sources.nixpkgs}/nixos/release.nix -A manualHTML.${system} -o ${out}";
      out = "./result/nixos-git-manual";
      dest = "${out}/share/doc/nixos/index.html";
    };
    hm = rec {
      cmd = "${fnix} build ${sources.home-manager}#docs-html --print-out-paths -o ${out}";
      out = "./result/hm-git-manual";
      dest = "${out}/share/doc/home-manager/index.xhtml";
    };
  };
  custom_scripts = [
    docs.build
    docs.browse.qute
    docs.browse.tmux
    noogle.build
    noogle.run
    upd
    fmt
    tmuxp'
  ];
  script_names' = builtins.concatStringsSep " " (builtins.map stripStorePrefix custom_scripts);
  # TODO get rid of this hacky menu, use numtide/devshells and devshells-lib (my centralized hacky one)
  menu = pkgs.writeScriptBin "menu" ''
    echo menu
    echo ${script_names'} | tr ' ' '\n'
  '';
  fmt = pkgs.writeScriptBin "fmt" ''
    nixfmt **/*.nix
    deadnix
    statix check
    mdsh
  '';
  upd = pkgs.writeScriptBin "upd" ''
    npins update
    rm -rf .direnv
    echo run direnv allow
  '';
  tmuxp' = pkgs.writeScriptBin "dev" "${b' pkgs.tmuxp} load -y .";
in
{
  shell = pkgs.mkShellNoCC {
    shellHook = ''
      echo $ menu
      ${b' menu}
    '';
    packages =
      with pkgs;
      [
        black
        (python3.withPackages (pp: with pp; [ beautifulsoup4 ]))
      ]
      ++ [
        nixfmt-rfc-style
        deadnix
        statix
        npins
        mdsh
        tmuxp
      ]
      ++ custom_scripts
      ++ [ menu ]
      ++ [
        docs.hm-docs
        docs.nix-docs
        docs.nixpkgs-docs
        docs.nixos-docs
      ];
  };
}
