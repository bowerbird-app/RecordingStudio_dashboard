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
      return unless heading?

      tag.div(class: "flex items-end justify-between gap-4") do
        safe_join([title, button_group].compact)
      end
    end

    def heading?
      @row.title.present? || @row.action || @row.buttons.any?
    end

    def title
      return if @row.title.blank?

      render(FlatPack::SectionTitle::Component.new(title: @row.title, spacing: :none,
                                                   class: "fp-on-backdrop mb-0 pb-0"))
    end

    def button_group
      parts = @row.buttons.map { |button| heading_button(button) }
      parts << action_link if @row.action
      return if parts.empty?

      tag.div(class: "flex items-center gap-4") { safe_join(parts) }
    end

    def action_link
      render_button(text: @row.action.label, href: @row.action.url)
    end

    def heading_button(button)
      render_button(text: button.label, href: button.url, icon: button.icon, http_method: button.http_method)
    end

    def render_button(text:, href:, icon: nil, http_method: nil)
      options = { text: text, href: href, style: :default, size: :sm }
      options[:icon] = icon if icon
      options[:method] = http_method if http_method
      render(FlatPack::Button::Component.new(**options))
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
