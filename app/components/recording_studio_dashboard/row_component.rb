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
      tag.section(class: "flex w-full flex-col gap-4", data: { dashboard_row: @row.id }) do
        safe_join([heading, body].compact)
      end
    end

    private

    def heading
      return description_text if bare_description?
      return if heading_empty?

      tag.div(class: "flex items-end justify-between gap-4") do
        safe_join([heading_copy, action_link].compact)
      end
    end

    def bare_description?
      @row.title.blank? && @row.action.nil? && @row.description.present?
    end

    def heading_empty?
      @row.title.blank? && @row.description.blank? && @row.action.nil?
    end

    def heading_copy
      return title if @row.title.present?

      description_text
    end

    def description_text
      return if @row.description.blank?

      tag.p(@row.description)
    end

    def title
      return if @row.title.blank?

      render(FlatPack::SectionTitle::Component.new(title: @row.title, subtitle: @row.description))
    end

    def action_link
      return if @row.action.nil?

      render(FlatPack::Button::Component.new(text: @row.action.label, href: @row.action.url, style: :ghost, size: :sm))
    end

    def body
      return empty_panel if @row.widgets.empty?

      render(FlatPack::Grid::Component.new(cols: 12, gap: @row.spacing)) do
        safe_join(@row.widgets.map { |widget| render(WidgetFrameComponent.new(widget: widget, context: @context)) })
      end
    end

    def empty_panel
      render(FlatPack::EmptyState::Component.new(title: @row.empty_state.message || "Nothing in this section",
                                                 size: :sm))
    end
  end
end
