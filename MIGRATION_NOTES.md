# Migration Notes

## Current Requirements

- Ruby 3.3 or newer
- Rails 8.1 or newer
- Recording Studio 6.2 (`~> 6.2` in the gemspec; dummy GitHub tag `v6.2.0`)
- Accessible dummy tag `v0.23.0`, Trashable dummy tag `v0.12.0` (`require: false`), Root Switchable dummy tag `v0.11.0`, Metrics dummy tag `v0.7.0`, and Cache dummy tag `v0.6.0`
- FlatPack dummy tag `v0.1.327` (`>= 0.1.327`, `< 0.2` in the gemspec)

Dashboard headers and section titles use Flatpack `.fp-on-backdrop`, which ships in `0.1.327`. Row actions are default buttons and stay outside that class. A registered row action shows only when a widget `prepare` returns `Preparation.content(..., truncated: true)`. Reload Flatpack CSS after the bump. Do not rebuild Tailwind for this class. Do not rerun the install generator.
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
