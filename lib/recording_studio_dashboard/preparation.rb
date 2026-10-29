# frozen_string_literal: true

module RecordingStudioDashboard
  class Preparation
    STATES = %i[content empty loading error].freeze

    attr_reader :state, :data, :message, :error

    def self.content(data = nil, truncated: false, **fields)
      raise ArgumentError, "pass one content payload" unless data.nil? || fields.empty?

      payload = data.nil? && fields.any? ? fields : data
      new(:content, payload, nil, nil, truncated: truncated)
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

    def initialize(state, data, message, error, truncated: false)
      raise ArgumentError, "unknown preparation state #{state}" unless STATES.include?(state)
      raise ArgumentError, "truncated is only valid for content" if truncated && state != :content

      @state = state
      @data = data
      @message = message
      @error = error
      @truncated = truncated
    end

    def truncated?
      @truncated
    end
  end
end
