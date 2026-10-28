# frozen_string_literal: true

module RecordingStudioDashboard
  Policy = Data.define(:reorder_rows, :reorder_widgets, :hide, :resize, :add) do
    def self.fixed
      new(reorder_rows: false, reorder_widgets: false, hide: false, resize: false, add: false)
    end

    def self.personalised
      new(reorder_rows: true, reorder_widgets: true, hide: true, resize: true, add: true)
    end

    def self.user_created
      personalised
    end

    def self.resolve(value)
      case value
      when Policy then value
      when :fixed then fixed
      when :personalised then personalised
      when :user_created then user_created
      else raise ArgumentError, "unknown dashboard policy #{value.inspect}"
      end
    end

    def uses_preferences?
      reorder_rows || reorder_widgets || hide || resize || add
    end
  end
end
