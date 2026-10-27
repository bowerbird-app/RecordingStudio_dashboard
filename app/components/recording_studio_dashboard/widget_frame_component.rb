# frozen_string_literal: true

require "flat_pack"

module RecordingStudioDashboard
  class WidgetFrameComponent < ViewComponent::Base
    # Tailwind scans these literals for the 12-column spans FlatPack::Grid uses at lg.
    SPAN_CLASSES = {
      1 => "col-span-1 md:col-span-1 lg:col-span-1",
      2 => "col-span-1 md:col-span-1 lg:col-span-2",
      3 => "col-span-1 md:col-span-1 lg:col-span-3",
      4 => "col-span-1 md:col-span-2 lg:col-span-4",
      5 => "col-span-1 md:col-span-2 lg:col-span-5",
      6 => "col-span-1 md:col-span-2 lg:col-span-6",
      7 => "col-span-2 md:col-span-3 lg:col-span-7",
      8 => "col-span-2 md:col-span-3 lg:col-span-8",
      9 => "col-span-2 md:col-span-3 lg:col-span-9",
      10 => "col-span-2 md:col-span-4 lg:col-span-10",
      11 => "col-span-2 md:col-span-4 lg:col-span-11",
      12 => "col-span-2 md:col-span-4 lg:col-span-12"
    }.freeze

    def initialize(widget:, context:)
      super()
      @widget = widget
      @context = context
    end

    def call
      tag.div(class: frame_class, data: frame_data) { body }
    end

    private

    def frame_class
      [SPAN_CLASSES.fetch(@widget.span), "min-w-0"].join(" ")
    end

    def frame_data
      { dashboard_placement: @widget.id, dashboard_widget: @widget.widget, dashboard_span: @widget.span,
        dashboard_state: @widget.preparation.state }
    end

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
