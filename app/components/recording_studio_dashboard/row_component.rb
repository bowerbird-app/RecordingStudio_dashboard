# frozen_string_literal: true

require "flat_pack"

module RecordingStudioDashboard
  class RowComponent < ViewComponent::Base
    def initialize(row:, context:)
      super()
      @row = row
      @context = context
    end

    def call
      tag.section(class: "flex w-full flex-col gap-3", data: { dashboard_row: @row.id }) do
        safe_join([heading, body].compact)
      end
    end

    private

    def heading
      return if @row.title.blank? && @row.action.nil?

      tag.div(class: "flex items-end justify-between gap-4") do
        safe_join([title, action_link].compact)
      end
    end

    def title
      return if @row.title.blank?

      render(FlatPack::SectionTitle::Component.new(title: @row.title, spacing: :none,
                                                   class: "fp-on-backdrop mb-0 pb-0"))
    end

    def action_link
      return if @row.action.nil?

      render(FlatPack::Button::Component.new(
               text: @row.action.label,
               href: @row.action.url,
               style: :default,
               size: :sm
             ))
    end

    def body
      return empty_panel if @row.widgets.empty?

      render(FlatPack::Grid::Component.new(cols: 12, gap: @row.spacing)) do |grid|
        @row.widgets.each do |widget|
          frame = WidgetFrameComponent.new(widget: widget, context: @context)
          grid.with_item(span: WidgetFrameComponent.item_span(widget.span), class: "min-w-0",
                         data: frame.frame_data) { render(frame) }
        end
      end
    end

    def empty_panel
      render(FlatPack::EmptyState::Component.new(title: @row.empty_state.message || "Nothing in this section",
                                                 size: :sm))
    end
  end
end
