let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  inherit (pkgs) lib;
  stripStorePrefix = import ./nix/lib/strip-store-prefix.nix lib;
  b' = lib.meta.getExe;
  noogle = {
    src = sources.noogle;
    # offline instance of migrate-doc-comments ?? am I crazy?
    # https://github.com/hsjobeki/nixpkgs/blob/master/.github/workflows/update-comments.yml
    build = pkgs.writeShellScriptBin "noogle-build" ''
      ${fnix} build ${sources.noogle}#ui -o result/noogle
    '';
    run = pkgs.writeShellScriptBin "noogle-run" ''
      ${b' noogle.build}
      ${b' pkgs.httplz} -q -x ./result/noogle/lib/node_modules/noogle/out
    '';
  };
  qutebrowser = {
    pkg = pkgs.qutebrowser;
    config = pkgs.writeText "docs-qute-conf.py" ''
      config.load_autoconfig()
      config.set("colors.webpage.darkmode.enabled", True)
    '';
  };
  mmdocs = { }; # todo get that github pr?
  multipageofficial = { }; # https://github.com/NixOS/nixpkgs/compare/nixos-24.05...GetPsyched:nixpkgs:render-docs?w=1
  nixpkgs-tracker = { }; # nixpkgs tracker
  nixpkgs-pr-tracker = { }; # pr-tracker
  #fnix = ''${b' pkgs.nix} --extra-experimental-features "nix-command flakes"'';
  fnix = "${b' pkgs.nix-output-monitor}";
  docs = {
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
    '';
    nix = {
      cmd = "${fnix} build ${sources.nix}#nix^doc --print-out-paths -o result/nix-latest";
      out = "./result/nix-latest";
      dest = "${docs.nix.out}-doc/share/doc/nix/manual/index.html";
    };
    nixpkgs = {
      cmd = "${fnix} build ${sources.nixpkgs}#nixpkgs-manual --print-out-paths -o result/nixpkgs-git-manual";
      out = "./result/nixpkgs-git-manual";
      dest = "${docs.nixpkgs.out}/share/doc/nixpkgs/manual.html";
    };
    nixos = {
      cmd = "${pkgs.nix}/bin/nix-build ${sources.nixpkgs}/nixos/release.nix -A manualHTML.x86_64-linux -o result/nixos-git-manual";
      out = "./result/nixos-git-manual";
      dest = "${docs.nixos.out}/share/doc/nixos/index.html";
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
  tmuxp' = pkgs.writeScriptBin "tmuxp-local" "${b' pkgs.tmuxp} load -y .";
in
pkgs.mkShellNoCC {
  shellHook = ''
    echo $ menu
    ${b' menu}
  '';
  packages =
    with pkgs;
    [
      black
      (python312.withPackages (pypkgs: with pypkgs; [ beautifulsoup4 ]))
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
    ++ [ menu ];
}
