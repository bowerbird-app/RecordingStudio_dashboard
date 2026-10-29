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
      render FlatPack::Card::Component.new(border: :strong, shadow: :none) do |card|
        card.body do
          tag.div(class: "space-y-2") do
            safe_join([
              render(FlatPack::SectionTitle::Component.new(
                       title: "Getting started",
                       size: :md,
                       spacing: :none,
                       level: :h3
                     )),
              tag.ul(class: "space-y-3 text-sm leading-6") do
                safe_join(@preparation.data.map { |step| tag.li(step, data: { checklist_step: step }) })
              end
            ])
          end
        end
      end
    end
  end
end
