# frozen_string_literal: true

module RecordingStudioDashboard
  class Preference < ActiveRecord::Base
    self.table_name = "recording_studio_dashboard_preferences"

    def self.overrides_for(dashboard_key:, actor:)
      return Overrides.none unless table_available?

      record = find_by(dashboard_key: dashboard_key.to_s, actor_type: actor.class.name, actor_id: actor.id)
      record ? Overrides.parse(record.overrides) : Overrides.none
    end

    def self.store!(dashboard_key:, actor:, overrides:)
      parsed = overrides.is_a?(Overrides) ? overrides : Overrides.parse(overrides)
      record = find_or_initialize_by(
        dashboard_key: dashboard_key.to_s,
        actor_type: actor.class.name,
        actor_id: actor.id
      )
      record.overrides = parsed.to_h
      record.save!
      parsed
    end

    def self.table_available?
      table_exists?
    rescue StandardError
      false
    end
    private_class_method :table_available?
  end
end
