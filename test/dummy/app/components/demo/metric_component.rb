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
      render FlatPack::Card::Component.new(style: :elevated) do |card|
        card.header { render FlatPack::PageTitle::Component.new(title: @preparation.data.fetch(:label), variant: :h3, class: "mb-0 pb-0") }
        card.body { tag.p(@preparation.data.fetch(:value).to_s, class: "text-4xl font-bold fp-tabular-nums") }
      end
    end
  end
end
