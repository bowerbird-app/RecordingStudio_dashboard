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
- Runtime dependencies are `rails`, `recording_studio` `~> 4.2`, and `flat_pack` `~> 0.1.196`.
