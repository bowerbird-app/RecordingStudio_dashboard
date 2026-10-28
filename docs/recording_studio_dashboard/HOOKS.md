# Engine hooks

`RecordingStudioDashboard::Configuration` holds one `RecordingStudio::Hooks` instance. The engine runs these events.

| Event | When |
| --- | --- |
| `:before_initialize` | Before host YAML and `config.x` are merged. |
| `:on_configuration` | After that merge. The argument is the configuration. |
| `:after_initialize` | After configuration is loaded. |

Model and controller extensions registered on that hooks object are applied in `to_prepare`. Dashboard registration does not go through these hooks. Call `RecordingStudioDashboard.register` and `register_widget` from a host initializer.

```ruby
RecordingStudioDashboard.configuration.hooks.on(:on_configuration) do |configuration|
  configuration
end
```
