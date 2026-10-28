# frozen_string_literal: true

require "recording_studio"
require "recording_studio_dashboard/version"
require "recording_studio_dashboard/engine"
require "recording_studio_dashboard/configuration"
require "recording_studio_dashboard/empty_state"
require "recording_studio_dashboard/preparation"
require "recording_studio_dashboard/policy"
require "recording_studio_dashboard/structures"
require "recording_studio_dashboard/widget_type"
require "recording_studio_dashboard/registry"
require "recording_studio_dashboard/span_math"
require "recording_studio_dashboard/overrides"
require "recording_studio_dashboard/placement_draft"
require "recording_studio_dashboard/definition_builder"
require "recording_studio_dashboard/override_applier"
require "recording_studio_dashboard/composer"

module RecordingStudioDashboard
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end

    def registry
      @registry ||= Registry.new
    end

    def reset!
      @registry = Registry.new
    end

    def register(id, policy: :fixed, &)
      definition = DefinitionBuilder.build(id, policy: policy, registry: registry, &)
      registry.add_dashboard(definition)
      definition
    end

    def register_widget(id, **)
      widget = WidgetType.build(id, **)
      registry.add_widget(widget)
      widget
    end

    def definition_from_layout(id, layout, policy: :user_created, header: nil)
      DefinitionBuilder.from_layout(id, layout, policy: policy, header: header, registry: registry)
    end

    def component(id, context:, actor: nil, overrides: nil)
      present(registry.dashboard(id), context: context, actor: actor, overrides: overrides)
    end

    def present(definition, context:, actor: nil, overrides: nil)
      chosen = overrides || preferences_for(definition, actor)
      DashboardComponent.new(definition: definition, context: context, overrides: chosen)
    end

    def preferences_for(definition, actor)
      return Overrides.none unless definition.policy.uses_preferences? && actor

      model = preference_model
      return Overrides.none unless model

      model.overrides_for(dashboard_key: definition.id, actor: actor)
    end

    def preference_model
      return unless defined?(ActiveSupport::Inflector)

      "RecordingStudioDashboard::Preference".safe_constantize
    end
  end
end
