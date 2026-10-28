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
  Placement = Data.define(:id, :widget, :span, :config, :visible_if, :mandatory, :empty_state)
  Row = Data.define(
    :id, :title, :description, :action, :spacing, :collapse, :visible_if, :empty_state, :placements
  )
  Definition = Data.define(:id, :header, :rows, :policy)
  Layout = Data.define(:id, :header, :rows)
  LaidRow = Data.define(:id, :title, :description, :action, :spacing, :widgets, :empty_state)
  LaidWidget = Data.define(:id, :widget, :span, :component, :config, :preparation, :empty_state)
end
