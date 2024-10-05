### What

Nix/Nixpkgs/Nixos ecosystem has tons of scattered resources, the goal of this PERSONAL project (for now) is to self-host them
- self-hosted doesn't mean offline access (but provide as much offline access as possible)
- ironic since no nix command works offline without internet access (by default atleast)
- try to use local nixpkgs checkout (possible ?)

- mmdoc (written in c, hmm)
  - ignore it? (ux is great tho)
- all manuals build steps (doc urls, s.o post)
  - a wiki article (Building Documentation?)
- nixpkgs/nixos manuals multi-paged (find the discussion, TODO, see https://github.com/NixOS/nixpkgs/pull/108063)
  - GetPsyched is working on multiple docs support (see https://github.com/GetPsyched/nixpkgs/commits/render-docs)
- [x] w3m/qutebrowser scripts like nixos-help (make it easier)
  - for nixpkgs, nixos, nix, hm manuals
  - open in browser the dashboard search page (for now just bookmarks to local services, like homer dashboard)
- [ ] nixos-search
- [ ] home-manager-options-search
  - can be hosted, requires a cron service to keep it updated (or think a manual refresh button)
  - todo: use nix to pin all the cdn js, bootstrap etc.
- [x] noogle
- all self-hosted (guide in wiki and/or provide a flake)
  - in the flake provide a nixos module and a home-manager module with modular services 
  - use httplz I guess? for noogle and home-manager-option-search (any non-static component)
  - a single search dashboard which can search across all these (?)
  - nixpkgs-tracker, pr-tracker (possible w/ no gh requests? i.e. offline?)
    - that tampermonkey script which adds it to the pr itself
    - add all of this in a wiki article with proper references to discourse/reddit/blog sources

## Setup

This is the old mmdoc thing, ignore it for now

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

- [ ] navi cheat hook
  - fails w/ direnv (used to work?)
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
