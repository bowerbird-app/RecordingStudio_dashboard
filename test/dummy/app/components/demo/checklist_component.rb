# frozen_string_literal: true

module Demo
  class ChecklistComponent < ViewComponent::Base
    STEPS = ["Name the studio", "Invite a collaborator", "Publish the first page"].freeze

    def self.prepare(_context, _config)
      RecordingStudioDashboard::Preparation.content(STEPS)
    end

    def initialize(context:, config:, preparation:)
      @context = context
      @config = config
      @preparation = preparation
    end

    def call
      render FlatPack::Card::Component.new(style: :outlined) do |card|
        card.header { render FlatPack::PageTitle::Component.new(title: "Getting started", variant: :h3, class: "mb-0 pb-0") }
        card.body do
          tag.ul(class: "space-y-3 text-sm leading-6") do
            safe_join(@preparation.data.map { |step| tag.li(step, data: { checklist_step: step }) })
          end
        end
      end
    end
  end
end
