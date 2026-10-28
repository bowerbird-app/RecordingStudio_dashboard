# frozen_string_literal: true

module RecordingStudioDashboard
  WidgetType = Data.define(
    :id, :component, :title, :description, :default_span, :supported_spans, :options, :permission,
    :empty_state, :visible_if
  ) do
    def self.build(id, component:, **attrs)
      new(**attributes(id, component, attrs))
    end

    def self.attributes(id, component, attrs)
      {
        id: id.to_sym, component: required_component(id, component),
        title: attrs[:title], description: attrs[:description],
        default_span: Integer(attrs.fetch(:default_span, 12)),
        supported_spans: attrs.fetch(:supported_spans, 1..12),
        options: Array(attrs.fetch(:options, [])).map(&:to_sym),
        permission: attrs[:permission], visible_if: attrs[:visible_if],
        empty_state: empty_from(attrs)
      }
    end

    def self.empty_from(attrs)
      EmptyState.coerce(
        attrs.fetch(:empty, :hide),
        message: attrs[:empty_message],
        component: attrs[:empty_component]
      )
    end

    def supports?(span)
      supported_spans.respond_to?(:cover?) ? supported_spans.cover?(span) : supported_spans.include?(span)
    end

    def self.required_component(id, component)
      raise ArgumentError, "widget #{id} needs a component" if component.nil?

      component
    end
    private_class_method :attributes, :empty_from, :required_component
  end
end
