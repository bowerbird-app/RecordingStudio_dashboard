# frozen_string_literal: true

module Demo
  class RecentItemsComponent < ViewComponent::Base
    ITEMS = [
      { title: "Spring release", detail: "Updated yesterday" },
      { title: "Tour photos", detail: "Updated 2 days ago" },
      { title: "Press quotes", detail: "Updated last week" },
      { title: "Radio session", detail: "Updated this morning" }
    ].freeze

    def self.prepare(_context, config)
      return RecordingStudioDashboard::Preparation.empty(message: "No recent items yet") if config[:source].to_s == "empty"

      limit = Integer(config.fetch(:limit, 3))
      display = config.fetch(:display, :grid).to_sym
      RecordingStudioDashboard::Preparation.content(items: ITEMS.first(limit), display: display)
    end

    def initialize(context:, config:, preparation:)
      @context = context
      @config = config
      @preparation = preparation
    end

    def call
      return render(carousel) if @preparation.data.fetch(:display) == :carousel

      render(FlatPack::Grid::Component.new(cols: 3, gap: :md)) do
        safe_join(items.map { |item| card(item) })
      end
    end

    private

    def card(item)
      render FlatPack::Card::Component.new(style: :default) do |card|
        card.header { render FlatPack::PageTitle::Component.new(title: item.fetch(:title), variant: :h3, class: "mb-0 pb-0") }
        card.body { tag.p(item.fetch(:detail), class: "text-sm leading-6", data: { collection_item: item.fetch(:title) }) }
      end
    end

    def carousel
      FlatPack::Carousel::Component.new(
        slides: items.map { |item| { type: :html, html: slide_html(item) } },
        items_per_view_desktop: 2,
        items_per_view_tablet: 1,
        aspect_ratio: "16/9",
        aria_label: "Recent items"
      )
    end

    def slide_html(item)
      tag.h3(item.fetch(:title)) + tag.p(item.fetch(:detail))
    end

    def items
      @preparation.data.fetch(:items)
    end
  end
end
