# frozen_string_literal: true

module RecordingStudioDashboard
  class Composer
    def self.call(definition:, context:, overrides: Overrides.none, registry: RecordingStudioDashboard.registry)
      new(definition, context, overrides, registry).call
    end

    def initialize(definition, context, overrides, registry)
      @definition = definition
      @context = context
      @registry = registry
      @rows = OverrideApplier.call(definition, overrides, registry)
    end

    def call
      Layout.new(id: @definition.id, header: @definition.header, rows: @rows.filter_map { |row| lay_row(row) })
    end

    private

    def lay_row(row)
      return nil unless visible?(row.visible_if)

      widgets = row.placements.filter_map { |placement| lay_placement(placement) }
      return nil if widgets.empty? && row.empty_state.policy == :hide

      apply_spans(row, widgets)
    end

    def lay_placement(placement)
      type = @registry.widget(placement.widget)
      return nil unless permitted?(type)
      return nil unless visible?(placement.visible_if)

      preparation = prepare(type, placement)
      empty_state = placement.empty_state
      return nil if preparation.state == :empty && empty_state.policy == :hide

      LaidWidget.new(
        id: placement.id, widget: type.id, span: placement.span, component: type.component,
        config: placement.config, preparation: preparation, empty_state: empty_state
      )
    end

    def apply_spans(row, widgets)
      spans = SpanMath.effective(widgets.map(&:span), row.collapse)
      laid = widgets.each_with_index.map { |widget, index| widget.with(span: spans.fetch(index)) }
      LaidRow.new(
        id: row.id, title: row.title, description: row.description, action: row.action,
        spacing: row.spacing, widgets: laid, empty_state: row.empty_state
      )
    end

    def prepare(type, placement)
      return Preparation.content(placement.config) unless type.component.respond_to?(:prepare)

      result = type.component.prepare(@context, placement.config)
      return result if result.is_a?(Preparation)

      raise TypeError, "#{type.component} prepare returned #{result.class}"
    rescue StandardError => e
      log_error(placement, e)
      Preparation.error(e)
    end

    def permitted?(type)
      type.permission.nil? || type.permission.call(@context)
    end

    def visible?(predicate)
      return true if predicate.nil?
      return predicate.call(@context) if predicate.respond_to?(:call)

      @context.public_send(predicate)
    end

    def log_error(placement, error)
      return unless defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger

      Rails.logger.error("[RecordingStudioDashboard] widget #{placement.id} #{error.full_message}")
    end
  end
end
