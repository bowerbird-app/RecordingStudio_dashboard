# frozen_string_literal: true

module RecordingStudioDashboard
  Header = Data.define(:component)
  HeadingAction = Data.define(:label, :url) do
    def self.coerce(value)
      return nil if value.nil?
      return value if value.is_a?(self)

      data = value.to_h.transform_keys(&:to_sym)
      new(label: data.fetch(:label), url: data.fetch(:url))
    end
  end
  HeadingButton = Data.define(:label, :url, :icon, :http_method, :visible_if) do
    def self.coerce_list(value)
      return [] if value.nil?
      raise ArgumentError, "unknown buttons #{value.inspect}" unless value.is_a?(Array)

      value.map { |entry| coerce(entry) }
    end

    def self.coerce(value)
      return value if value.is_a?(self)

      data = button_hash(value)
      new(
        label: data.fetch(:label),
        url: data.fetch(:url),
        icon: icon_name(data[:icon]),
        http_method: http_method_name(data[:method]),
        visible_if: predicate(data[:visible_if])
      )
    end

    def self.button_hash(value)
      raise ArgumentError, "unknown button #{value.inspect}" unless value.is_a?(Hash)

      data = value.to_h.transform_keys(&:to_sym)
      return data if data[:label].present? && data[:url].present?

      raise ArgumentError, "unknown button #{value.inspect}"
    end

    def self.icon_name(value)
      return if value.nil?

      name = value.to_s
      name.empty? ? nil : name
    end

    def self.http_method_name(value)
      return if value.nil?

      symbol = value.to_sym
      raise ArgumentError, "unknown method #{value.inspect}" unless allowed_methods.include?(symbol)

      symbol
    end

    def self.allowed_methods
      %i[get post put patch delete]
    end

    def self.predicate(value)
      return if value.nil?
      return value if value.respond_to?(:call)

      value.to_sym
    end
    private_class_method :button_hash, :icon_name, :http_method_name, :allowed_methods, :predicate
  end
  Placement = Data.define(:id, :widget, :span, :config, :visible_if, :mandatory, :empty_state)
  Row = Data.define(
    :id, :title, :description, :action, :buttons, :spacing, :collapse, :visible_if, :empty_state, :placements
  )
  Definition = Data.define(:id, :header, :rows, :policy)
  Layout = Data.define(:id, :header, :rows)
  LaidRow = Data.define(:id, :title, :description, :action, :buttons, :spacing, :widgets, :empty_state)
  LaidWidget = Data.define(:id, :widget, :span, :component, :config, :preparation, :empty_state)
end
