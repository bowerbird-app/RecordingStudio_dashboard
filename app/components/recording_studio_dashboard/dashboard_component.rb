# frozen_string_literal: true

require "flat_pack"

module RecordingStudioDashboard
  class DashboardComponent < ViewComponent::Base
    def initialize(definition:, context:, overrides: Overrides.none)
      super()
      @context = context
      @layout = Composer.call(definition: definition, context: context, overrides: overrides)
    end

    def call
      tag.div(class: "flex w-full flex-col gap-12", data: { dashboard: @layout.id }) do
        safe_join([header, *rows].compact)
      end
    end

    private

    def header
      return if @layout.header.nil?

      tag.div(class: "fp-on-backdrop") do
        render(@layout.header.component.new(context: @context))
      end
    end

    def rows
      @layout.rows.map { |row| render(RowComponent.new(row: row, context: @context)) }
    end
  end
end
