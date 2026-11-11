# frozen_string_literal: true

require "flat_pack"

module RecordingStudioDashboard
  class WidgetFrameComponent < ViewComponent::Base
    # Integer placements map onto Flatpack Grid cols: 12. A hash placement is
    # returned unchanged. Spans 4-6 are full width at base (2 of 2 tracks).
    # Tailwind scans GRID_UTILITIES. Flatpack emits those names at runtime.
    GRID_UTILITIES = %w[
      grid-cols-2 md:grid-cols-4 lg:grid-cols-12
      col-span-1 col-span-2 col-span-3 col-span-4 col-span-5 col-span-6
      col-span-7 col-span-8 col-span-9 col-span-10 col-span-11 col-span-12 col-span-full
      md:col-span-1 md:col-span-2 md:col-span-3 md:col-span-4 md:col-span-5 md:col-span-6
      md:col-span-7 md:col-span-8 md:col-span-9 md:col-span-10 md:col-span-11 md:col-span-12
      lg:col-span-1 lg:col-span-2 lg:col-span-3 lg:col-span-4 lg:col-span-5 lg:col-span-6
      lg:col-span-7 lg:col-span-8 lg:col-span-9 lg:col-span-10 lg:col-span-11 lg:col-span-12
    ].freeze
    ITEM_SPANS = {
      1 => { base: 1, md: 1, lg: 1 },
      2 => { base: 1, md: 1, lg: 2 },
      3 => { base: 1, md: 1, lg: 3 },
      4 => { base: 2, md: 2, lg: 4 },
      5 => { base: 2, md: 2, lg: 5 },
      6 => { base: 2, md: 2, lg: 6 },
      7 => { base: 2, md: 3, lg: 7 },
      8 => { base: 2, md: 3, lg: 8 },
      9 => { base: 2, md: 3, lg: 9 },
      10 => { base: 2, md: 4, lg: 10 },
      11 => { base: 2, md: 4, lg: 11 },
      12 => { base: 2, md: 4, lg: 12 }
    }.freeze

    def self.item_span(span)
      return span if span.is_a?(Hash)

      ITEM_SPANS.fetch(span)
    end

    def initialize(widget:, context:)
      super()
      @widget = widget
      @context = context
    end

    def call
      body
    end

    def frame_data
      { dashboard_placement: @widget.id, dashboard_widget: @widget.widget,
        dashboard_span: SpanMath.layout_width(@widget.span),
        dashboard_state: @widget.preparation.state }
    end

    private

    def body
      case @widget.preparation.state
      when :content then render_widget
      when :empty then empty_body
      when :loading then render(FlatPack::Skeleton::Component.new(variant: :rectangle))
      when :error then render(FlatPack::Alert::Component.new(title: "This widget could not be displayed.",
                                                             style: :danger))
      end
    end

    def render_widget
      render(@widget.component.new(context: @context, config: @widget.config, preparation: @widget.preparation))
    end

    def empty_body
      case @widget.empty_state.policy
      when :message then render(FlatPack::EmptyState::Component.new(title: empty_message, size: :sm))
      when :placeholder then render(FlatPack::Skeleton::Component.new(variant: :rectangle))
      when :custom then render(@widget.empty_state.component.new(context: @context, config: @widget.config,
                                                                 preparation: @widget.preparation))
      end
    end

    def empty_message
      @widget.preparation.message || @widget.empty_state.message || "Nothing to show yet"
    end
  end
end
