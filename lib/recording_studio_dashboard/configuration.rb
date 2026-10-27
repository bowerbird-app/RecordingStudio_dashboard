# frozen_string_literal: true

module RecordingStudioDashboard
  class Configuration
    attr_reader :hooks

    def initialize
      @hooks = RecordingStudio::Hooks.new
    end

    def to_h
      { hooks_registered: hooks.instance_variable_get(:@registry).transform_values(&:size) }
    end

    def merge!(hash)
      return unless hash.respond_to?(:each)

      hash.each do |key, value|
        setter = "#{key}="
        public_send(setter, value) if respond_to?(setter)
      end
    end
  end
end
