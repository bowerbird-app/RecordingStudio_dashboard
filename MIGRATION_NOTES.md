# Migration Notes

## Current Requirements

- Ruby 3.3 or newer
- Rails 8.1 or newer
- Recording Studio 7.x (`>= 7.0`, `< 8.0` in the gemspec; dummy GitHub tag `v7.0.0`)
- Accessible dummy tag `v0.43.0`, Trashable dummy tag `v0.16.0` (`require: false`), Root Switchable dummy tag `v0.15.0`, Metrics dummy tag `v0.8.0`, and Cache dummy tag `v0.6.3`
- FlatPack `0.1.331` through `0.x` (`>= 0.1.331`, `< 1.0` in the gemspec; dummy GitHub tag `v0.1.376`)

Dashboard headers and section titles use Flatpack `.fp-on-backdrop`, which ships in `0.1.327`. Row actions and heading buttons are default buttons and stay outside that class. A registered row action shows only when a widget `prepare` returns `Preparation.content(..., truncated: true)`. Heading `buttons:` show even when that action is hidden. Reload Flatpack CSS after the bump. Do not rebuild Tailwind for this class. Do not rerun the install generator.

From `0.3.0`, integer spans 4-6 are full width on phones. Existing `span: 6` placements do not need a registration change. Pass a span hash only when a placement must keep a different phone width.

From `0.4.0`, a row may set `buttons:` to a list of `{ label, url }` hashes. Optional keys are `icon`, `method`, and `visible_if`. Existing rows do not need a registration change.

From `0.4.1`, pin `recording_studio_dashboard` to `0.4.1`. The gemspec allows Flatpack `>= 0.1.331`, `< 1.0` and Recording Studio `~> 6.0`, `>= 6.2`. Development and dummy GitHub tags are Recording Studio `v6.10.0`, Flatpack `v0.1.366`, Accessible `v0.37.0`, Trashable `v0.14.1`, Root Switchable `v0.15.0`, Metrics `v0.8.0`, and Cache `v0.6.3`.

From `0.4.2`, pin `recording_studio_dashboard` to `0.4.2` and Recording Studio to `7.x`. Create roots with `RecordingStudio.create_root_recording!(recordable, actor:)`. `root_recording_for` only finds a root and returns `nil`. Allow that create in `authorize_write` when `root_recording` is nil. Dummy seeds look up kept children with `Recording.kept`. Core 7 adds no migration for the root split.

Recording Studio `6.5` and newer refuses a write until `config.authorize_write` is set. The dummy policy allows a persisted user to create a root, then an edit grant on that root, and an admin grant (or Accessible's access-creation context) when the recordable is an access grant. Seeds call `create_root_recording!` and `bootstrap_owner_access!` before child recordings. The mounted root switcher also requires an Accessible `:view` grant on the current root. Trashable `0.14.0` adds `purge_at` on `recording_studio_recordings`. Recording Studio `6.9` requires `root_recording_id` on `recording_studio_events`. The dummy copies `20261114090000_add_root_recording_id_to_recording_studio_events`. Run the dummy migrations after the pin bump. Core 7.0.0 adds no further migration.
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
