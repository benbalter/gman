# CLAUDE.md

Gman is a Ruby gem that checks whether an email address or domain belongs to a government or military organization, using the crowd-sourced list in [`config/domains.txt`](config/domains.txt).

## Commands

- [`script/bootstrap`](script/bootstrap) installs dependencies.
- [`script/cibuild`](script/cibuild) runs rspec, RuboCop, [`script/dedupe`](script/dedupe) and a gem build. It's what CI runs, so run it before committing.
- [`script/add GROUP DOMAIN...`](script/add) adds domains to a group in `config/domains.txt` with the importer's checks, rather than hand-editing the file. [`clean.yml`](.github/workflows/clean.yml) re-alphabetizes and dedupes the list after every push to `main`.

## Generated files

[`config/vendor/academic.txt`](config/vendor/academic.txt) and [`config/vendor/dotgovs.csv`](config/vendor/dotgovs.csv) are overwritten by [`script/vendor-swot`](script/vendor-swot) and [`script/vendor-gov-list`](script/vendor-gov-list), which [`vendor.yml`](.github/workflows/vendor.yml) runs monthly. Don't hand-edit them; a hand edit is lost on the next vendor run.

## Releasing

[`script/release`](script/release) builds the gem, runs `gem push` to RubyGems, then tags `vX.Y.Z` and pushes `main` and the tag. It asks for no confirmation, so running it publishes immediately.

Releases happen only after the owner explicitly approves them. Agents may open a PR that bumps [`lib/gman/version.rb`](lib/gman/version.rb), but must never run `script/release` or `gem push`, push a tag, or create a GitHub Release. A published gem version can't be reused, even if it's yanked.
