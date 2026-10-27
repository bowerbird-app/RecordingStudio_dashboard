# Changelog

## [0.1.0] - 2026-10-27

### Added

- Dashboard, row, and widget registration. Definitions stay in Ruby.
- A 12-column layout with `:expand` and `:preserve` when a placement is hidden.
- Permission checks before widget `prepare`, plus visibility predicates and empty policies `:hide`, `:message`, `:placeholder`, and `:custom`.
- Fixed dashboards, personalised override rows, and `definition_from_layout` for user-created boards.
- Dummy dashboards for a greeting header, a mixed row, a collection widget in grid and carousel, metric widgets, empty rows, and a personalised hide.

### Changed

- The gem name is `recording_studio_dashboard` at version `0.1.0`.
- Runtime dependencies are `rails`, `recording_studio` `~> 6.2`, and `flat_pack` `>= 0.1.315`, `< 0.2`.
- The dummy app uses Recording Studio `v6.2.0` and fills the default layout background image slot.
- Development and dummy locks use Flatpack `v0.1.315` so `view_component` is `4.20.0`. `crass` is `1.0.8` and `net-ssh` is `7.3.8`.
