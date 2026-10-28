# frozen_string_literal: true

module RecordingStudioDashboard
  class Registry
    def initialize
      @dashboards = {}
      @widgets = {}
    end

    def add_dashboard(definition)
      raise ArgumentError, "dashboard #{definition.id} is already registered" if @dashboards.key?(definition.id)

      @dashboards[definition.id] = definition
    end

    def add_widget(widget)
      raise ArgumentError, "widget #{widget.id} is already registered" if @widgets.key?(widget.id)

      @widgets[widget.id] = widget
    end

    def dashboard(id)
      @dashboards.fetch(id.to_sym) { raise KeyError, "unknown dashboard #{id}" }
    end

    def widget(id)
      @widgets.fetch(id.to_sym) { raise KeyError, "unknown widget #{id}" }
    end
  end
end
