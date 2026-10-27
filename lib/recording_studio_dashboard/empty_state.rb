# frozen_string_literal: true

module RecordingStudioDashboard
  class EmptyState < Data.define(:policy, :message, :component)
    POLICIES = %i[hide message placeholder custom].freeze

    def self.hide
      new(policy: :hide, message: nil, component: nil)
    end

    def self.coerce(value, message: nil, component: nil)
      case value
      when EmptyState then value
      when nil, :hide then hide
      when :message, :placeholder, :custom
        checked(value, message, component)
      when Hash then from_hash(value, message, component)
      else raise ArgumentError, "unknown empty state #{value.inspect}"
      end
    end

    def self.from_hash(value, message, component)
      data = value.to_h.transform_keys(&:to_sym)
      coerce(data.fetch(:policy), message: data[:message] || message, component: data[:component] || component)
    end

    def self.checked(policy, message, component)
      raise ArgumentError, "unknown empty state #{policy.inspect}" unless POLICIES.include?(policy)

      new(policy: policy, message: message, component: component)
    end
    private_class_method :from_hash, :checked
  end
end
