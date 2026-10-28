# frozen_string_literal: true

module RecordingStudioDashboard
  class Preparation
    STATES = %i[content empty loading error].freeze

    attr_reader :state, :data, :message, :error

    def self.content(data = nil)
      new(:content, data, nil, nil)
    end

    def self.empty(message: nil)
      new(:empty, nil, message, nil)
    end

    def self.loading
      new(:loading, nil, nil, nil)
    end

    def self.error(error, message: nil)
      new(:error, nil, message, error)
    end

    def initialize(state, data, message, error)
      raise ArgumentError, "unknown preparation state #{state}" unless STATES.include?(state)

      @state = state
      @data = data
      @message = message
      @error = error
    end
  end
end
