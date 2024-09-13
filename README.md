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

