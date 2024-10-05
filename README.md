### What

- mmdoc (written in c, hmm)
- all manuals build steps (doc urls, s.o post)
  - a wiki article
- nixpkgs/nixos manuals multi-paged (find the discussion, TODO, see https://github.com/NixOS/nixpkgs/pull/108063)
- w3m/qutebrowser scripts like nixos-help (make it easier)
  - for nixpkgs, nixos, nix, hm manuals
- nixos-search, nixos-hm-search, noogle, all self-hosted (guide in wiki and/or provide a flake)
  - add reasoning, incase your offline, local nixpkgs checkout reused
  - nixpkgs-tracker, pr-tracker (possible w/ no gh requests? i.e. offline?)
    - that tampermonkey script which adds it to the pr itself
    - add all of this in a wiki article with proper references to discourse/reddit/blog sources

## Setup

```
direnv allow # nix develop
python main.py $(nix-build /shed/Projects/nixhome/nixpkgs -
A nixpkgs-manual --no-out-link)/share/doc/nixpkgs/manual.html > /shed/Projects/nixhome/nixpkgs/doc/toc.md
```

## TODO

- mmdoc (see the mmdoc pr nixpkgs#108063)
  - lib functions .md.in chapter
    - maybe mmdoc needs to run inside the environment setup by `doc/doc-support/package.nix` as the final setup
  - See https://github.com/NixOS/nixpkgs/pull/108063
    - Seems like mmdoc will not be official since python more approachable than C (agreed)
    - Seems like toc.md is hardcoded so my time wasn't entirely wasted
    - minidoc -> not the full docs
    - multi-page docs are on the way from the [matrix discussion](https://github.com/NixOS/nixpkgs/pull/108063#issuecomment-2001602381)

- GetPsyched is working on multiple docs support (see https://github.com/GetPsyched/nixpkgs/commits/render-docs)

- [ ] navi cheat hook
  - fails (used to work?)
- [ ] navi cheats
- [ ] menu | fzf, deadnix|statix etc via fzf
  - see datastar?

### Setup

```$ as bash
# direnv allow
menu
```

```bash
menu
docs-build
docs-browse-qute
docs-browse-tmux
noogle-build
noogle-run
upd
fmt
docs-tmuxp
```
