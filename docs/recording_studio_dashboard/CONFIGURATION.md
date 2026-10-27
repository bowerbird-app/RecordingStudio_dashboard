# Configuration

`RecordingStudioDashboard::Configuration` stores a `RecordingStudio::Hooks` instance. It has no API key, feature flag, or timeout setting. `merge!` calls a setter only when that setter exists, so unknown YAML keys are ignored.

`to_h` returns the count of callbacks registered on each hook.

Register dashboards in `config/initializers/recording_studio_dashboard.rb`. See `ARCHITECTURE.md`.

The engine still loads host config in this order.

1. `Configuration#initialize`
2. `config/recording_studio_dashboard.yml`, when Rails can read it
3. `config.x.recording_studio_dashboard`
4. The host initializer, which runs as part of normal Rails boot and can call `configure`

The dummy app pins Recording Studio to GitHub tag `v4.7.0` and keeps `config.require_recordable_declarations = true`. `StudioBoard` declares `root: false` and `allowed_parent_types: ["Workspace"]`.
