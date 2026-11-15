# Configuration

`RecordingStudioDashboard::Configuration` stores a `RecordingStudio::Hooks` instance and a `layout` setting. It has no API key, feature flag, or timeout setting. `merge!` calls a setter only when that setter exists, so unknown YAML keys are ignored.

`layout` defaults to `nil`. `RecordingStudio::Layout.accept` validates the value. Pass a layout name, `false`, or a callable that accepts `controller:`. Engine controllers call `recording_studio_layout { RecordingStudioDashboard.configuration.layout }`. A `nil` setting follows `RecordingStudio.configuration.layout`, then `recording_studio/default_layout`.

`to_h` returns the count of callbacks registered on each hook.

Register dashboards in `config/initializers/recording_studio_dashboard.rb`. See `ARCHITECTURE.md`.

The engine still loads host config in this order.

1. `Configuration#initialize`
2. `config/recording_studio_dashboard.yml`, when Rails can read it
3. `config.x.recording_studio_dashboard`
4. The host initializer, which runs as part of normal Rails boot and can call `configure`

The dummy app pins Recording Studio to GitHub tag `v6.10.0` and keeps `config.require_recordable_declarations = true`. `StudioBoard` declares `root: false` and `allowed_parent_types: ["Workspace"]`.
