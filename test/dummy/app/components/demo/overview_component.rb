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
      render FlatPack::Card::Component.new do |card|
        card.body do
          tag.div(class: "space-y-2") do
            safe_join([
              tag.h3("Studio overview", class: "text-lg font-semibold leading-tight"),
              tag.p(@preparation.data.fetch(:summary), class: "text-sm leading-6")
            ])
          end
        end
      end
    end
  end
end
