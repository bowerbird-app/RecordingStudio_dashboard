# frozen_string_literal: true

module RecordingStudioDashboard
  module SpanMath
    # Dashboard rows use Flatpack Grid cols: 12. Track counts match that preset,
    # including cascaded sm and xl. Collapse and data-dashboard-span use :lg,
    # or the largest value when :lg is omitted.
    GRID_TRACKS = { base: 2, sm: 2, md: 4, lg: 12, xl: 12 }.freeze
    GRID_BREAKPOINTS = GRID_TRACKS.keys.freeze

    module_function

    def coerce(value)
      value.is_a?(Hash) ? coerce_hash(value) : Integer(value)
    end

    def layout_width(span)
      return span if span.is_a?(Integer)

      span.fetch(:lg) { span.values.max }
    end

    def effective(spans, collapse)
      widths = spans.map { |span| layout_width(span) }
      return spans if collapse == :preserve || spans.empty? || widths.sum >= 12

      share, remainder = (12 - widths.sum).divmod(spans.length)
      widths.each_with_index.map { |span, index| [span + share + (index < remainder ? 1 : 0), 12].min }
    end

    def coerce_hash(value)
      raise ArgumentError, "span hash cannot be empty" if value.empty?

      keys = value.keys.map(&:to_sym)
      unknown = keys - GRID_BREAKPOINTS
      if unknown.any?
        raise ArgumentError,
              "invalid span breakpoints: #{unknown.join(', ')}. Must be one of: #{GRID_BREAKPOINTS.join(', ')}"
      end

      value.to_h { |key, count| coerce_breakpoint(key.to_sym, count) }.freeze
    end
    private_class_method :coerce_hash

    def coerce_breakpoint(breakpoint, count)
      tracks = GRID_TRACKS.fetch(breakpoint)
      integer = Integer(count)
      unless (1..tracks).cover?(integer)
        raise ArgumentError,
              "invalid span #{breakpoint}: #{count.inspect}. Must be an integer from 1 to #{tracks}"
      end

      [breakpoint, integer]
    end
    private_class_method :coerce_breakpoint
  end
end
