# frozen_string_literal: true

module Demo
  class MetricComponent < ViewComponent::Base
    def self.prepare(context, config)
      raise "loaded without permission" if context.fail_if_loaded
      return RecordingStudioDashboard::Preparation.empty(message: "No figure yet") if config[:value].nil?

      RecordingStudioDashboard::Preparation.content(config)
    end

    def initialize(context:, config:, preparation:)
      @context = context
      @config = config
      @preparation = preparation
    end

    def call
      render FlatPack::Card::Component.new(shadow: :md) do |card|
        card.body do
          tag.div(class: "space-y-2") do
            safe_join([
              tag.h3(@preparation.data.fetch(:label), class: "text-lg font-semibold leading-tight"),
              tag.p(@preparation.data.fetch(:value).to_s, class: "text-4xl font-bold fp-tabular-nums")
            ])
          end
        end
      end
    end
  end
end
