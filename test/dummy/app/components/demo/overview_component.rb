# frozen_string_literal: true

module Demo
  class OverviewComponent < ViewComponent::Base
    def self.prepare(context, _config)
      RecordingStudioDashboard::Preparation.content(summary: "#{context.studio_name} is ready")
    end

    def initialize(context:, config:, preparation:)
      @context = context
      @config = config
      @preparation = preparation
    end

    def call
      render FlatPack::Card::Component.new(style: :default) do |card|
        card.header { render FlatPack::PageTitle::Component.new(title: "Studio overview", variant: :h3, class: "mb-0 pb-0") }
        card.body { tag.p(@preparation.data.fetch(:summary), class: "text-sm leading-6") }
      end
    end
  end
end
