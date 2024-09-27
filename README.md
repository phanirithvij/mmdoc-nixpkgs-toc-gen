## What

A script to generate multi-page nixpkgs manual using ryanm's [mmdoc](https://github.com/ryantm/mmdoc)

## Why

https://ryantm.github.io/nixpkgs looks good and multi page manual is great
But I can't find the repo to generate the table of contents (toc.md)
So trying to recreate it as much as possible.

## Setup

```
direnv allow # nix develop
python main.py $(nix-build /shed/Projects/nixhome/nixpkgs -
A nixpkgs-manual --no-out-link)/share/doc/nixpkgs/manual.html > /shed/Projects/nixhome/nixpkgs/doc/toc.md
```

## TODO

- lib functions .md.in chapter
    - maybe mmdoc needs to run inside the environment setup by `doc/doc-support/package.nix` as the final setup

- See https://github.com/NixOS/nixpkgs/pull/108063
    - Seems like mmdoc will not be official since python more approachable than C (agreed)
    - Seems like toc.md is hardcoded so my time wasn't entirely wasted
    - minidoc -> not the full docs
    - multi-page docs are on the way from the [matrix discussion](https://github.com/NixOS/nixpkgs/pull/108063#issuecomment-2001602381)
    - abandon effort for now?

- GetPsyched is working on multiple docs support (see https://github.com/GetPsyched/nixpkgs/commits/render-docs)

- [ ] A nix script which builds all docs
- [ ] A nix script which opens all docs in w3m tmuxp (something)
- [ ] A nix script which opens all docs in qutebrowser (saw someone doing it in github issue or somewhere)
