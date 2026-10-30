# frozen_string_literal: true

require "flat_pack"

module RecordingStudioDashboard
  class WidgetFrameComponent < ViewComponent::Base
    # Proportional spans for a 12-column grid. FlatPack has no scale-with-columns
    # span, so Dashboard still owns these hashes. A hash is emitted as written.
    ITEM_SPANS = {
      1 => { base: 1, md: 1, lg: 1 },
      2 => { base: 1, md: 1, lg: 2 },
      3 => { base: 1, md: 1, lg: 3 },
      4 => { base: 1, md: 2, lg: 4 },
      5 => { base: 1, md: 2, lg: 5 },
      6 => { base: 1, md: 2, lg: 6 },
      7 => { base: 2, md: 3, lg: 7 },
      8 => { base: 2, md: 3, lg: 8 },
      9 => { base: 2, md: 3, lg: 9 },
      10 => { base: 2, md: 4, lg: 10 },
      11 => { base: 2, md: 4, lg: 11 },
      12 => { base: 2, md: 4, lg: 12 }
    }.freeze

    def self.item_span(columns)
      ITEM_SPANS.fetch(columns)
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
      { dashboard_placement: @widget.id, dashboard_widget: @widget.widget, dashboard_span: @widget.span,
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
