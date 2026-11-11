# Migration Notes

## Current Requirements

- Ruby 3.3 or newer
- Rails 8.1 or newer
- Recording Studio 6.2 (`~> 6.2` in the gemspec; dummy GitHub tag `v6.3.0`)
- Accessible dummy tag `v0.24.0`, Trashable dummy tag `v0.12.2` (`require: false`), Root Switchable dummy tag `v0.11.4`, Metrics dummy tag `v0.7.2`, and Cache dummy tag `v0.6.2`
- FlatPack dummy tag `v0.1.341` (`>= 0.1.331`, `< 0.2` in the gemspec)

Dashboard headers and section titles use Flatpack `.fp-on-backdrop`, which ships in `0.1.327`. Row actions and heading buttons are default buttons and stay outside that class. A registered row action shows only when a widget `prepare` returns `Preparation.content(..., truncated: true)`. Heading `buttons:` show even when that action is hidden. Reload Flatpack CSS after the bump. Do not rebuild Tailwind for this class. Do not rerun the install generator.

From `0.3.0`, integer spans 4-6 are full width on phones. Existing `span: 6` placements do not need a registration change. Pass a span hash only when a placement must keep a different phone width.

From `0.4.0`, a row may set `buttons:` to a list of `{ label, url }` hashes. Optional keys are `icon`, `method`, and `visible_if`. Pin `recording_studio_dashboard` to `0.4.0`. Existing rows do not need a registration change.
- Public RubyGems and GitHub access for dependency installation

## Verification

Install both bundles and run the complete gem and dummy app test path:

```bash
bundle install
BUNDLE_GEMFILE=test/dummy/Gemfile bundle install
bundle exec rake test:all
```

Run the dummy app from its directory for browser verification:

```bash
cd test/dummy
bin/dev
```

Use the [FlatPack repository](https://github.com/bowerbird-app/flatpack) and the live FlatPack demo linked from the top-level README for current component documentation.
