# frozen_string_literal: true

module RecordingStudioDashboard
  module SpanMath
    module_function

    def effective(spans, collapse)
      return spans if collapse == :preserve || spans.empty? || spans.sum >= 12

      share, remainder = (12 - spans.sum).divmod(spans.length)
      spans.each_with_index.map { |span, index| [span + share + (index < remainder ? 1 : 0), 12].min }
    end
  end
end
