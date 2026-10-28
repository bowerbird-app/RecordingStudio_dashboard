# Changelog

## [Unreleased]

### Changed

- Dummy overview, checklist, metric, and recent-item widgets use Flatpack `SectionTitle` for card and carousel headings.
- Row heading actions use a Flatpack default button (`style: :default`, `size: :sm`) instead of ghost. The action stays outside `.fp-on-backdrop` so the filled pill keeps dark type. Hosts see this after they pin this revision. No Featured In change is required.
- The dashboard column uses `gap-12` between the header and rows so sections sit farther apart. The gap inside a row stays `gap-3`.

## [0.1.0] - 2026-10-27

### Added

- Dashboard, row, and widget registration. Definitions stay in Ruby.
- A 12-column layout with `:expand` and `:preserve` when a placement is hidden.
- Permission checks before widget `prepare`, plus visibility predicates and empty policies `:hide`, `:message`, `:placeholder`, and `:custom`.
- Fixed dashboards, personalised override rows, and `definition_from_layout` for user-created boards.
- Dummy dashboards for a greeting header, a mixed row, a collection widget in grid and carousel, metric widgets, empty rows, and a personalised hide.

### Changed

- The gem name is `recording_studio_dashboard` at version `0.1.0`.
- Runtime dependencies are `rails`, `recording_studio` `~> 6.2`, and `flat_pack` `>= 0.1.327`, `< 0.2`.
- The dummy app uses Recording Studio `v6.2.0` and fills the default layout background image slot.
- Development and dummy locks use Flatpack `v0.1.327` so `view_component` is `4.20.0`. `crass` is `1.0.8` and `net-ssh` is `7.3.8`.
- Dashboard headers and section titles use `.fp-on-backdrop`. Page text follows a layout photo. The widget grid does not, so cards keep their own text. Reload Flatpack CSS. Do not rebuild Tailwind for this class.
- The dummy top nav uses default buttons and stays outside `.fp-on-backdrop`. That class sets page text to the photo color. It does not retarget `--button-default-text-color`, and the default fill stays light, so those buttons stay dark on a light pill.
