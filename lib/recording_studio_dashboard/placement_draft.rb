# frozen_string_literal: true

module RecordingStudioDashboard
  class PlacementDraft
    def initialize(widget, **options)
      @widget = widget
      @id = options[:id]
      @span = options[:span]
      @config = options.fetch(:config, {})
      @visible_if = options[:visible_if]
      @mandatory = options.fetch(:mandatory, false)
      @empty = options[:empty]
    end

    def visible_if(predicate)
      @visible_if = predicate
    end

    def mandatory(value: true)
      @mandatory = value
    end

    def span(value)
      @span = value
    end

    def config(value)
      @config = value
    end

    def build(registry, claim)
      type = registry.widget(@widget)
      chosen = chosen_span(type)
      placement_id = (@id || type.id).to_sym
      claim.call(placement_id)
      assemble(type, placement_id, chosen)
    end

    private

    def chosen_span(type)
      chosen = Integer(@span || type.default_span)
      raise ArgumentError, "span #{chosen} is not supported for #{type.id}" unless type.supports?(chosen)

      chosen
    end

    def assemble(type, placement_id, chosen)
      Placement.new(
        id: placement_id,
        widget: type.id,
        span: chosen,
        config: normalize(type),
        visible_if: @visible_if,
        mandatory: @mandatory == true,
        empty_state: resolved_empty(type)
      )
    end

    def resolved_empty(type)
      return type.empty_state if @empty.nil?

      EmptyState.coerce(@empty)
    end

    def normalize(type)
      raw = @config.to_h
      unknown = raw.keys.map(&:to_sym) - type.options
      raise ArgumentError, "unknown options for #{type.id}: #{unknown.join(', ')}" if unknown.any?

      raw.transform_keys(&:to_sym)
    end
  end
end
