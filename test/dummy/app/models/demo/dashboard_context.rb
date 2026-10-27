# frozen_string_literal: true

module Demo
  class DashboardContext
    attr_reader :name, :studio_name, :fail_if_loaded

    def initialize(actor:, onboarding_incomplete:, show_activity:, permit_metrics:, fail_if_loaded: false)
      @name = actor.email.to_s.split("@").first.to_s.capitalize.presence || "there"
      @studio_name = "Studio Workspace"
      @onboarding_incomplete = onboarding_incomplete
      @show_activity = show_activity
      @permit_metrics = permit_metrics
      @fail_if_loaded = fail_if_loaded
    end

    def self.for(page, actor)
      flags = PAGE_FLAGS.fetch(page.to_sym) { PAGE_FLAGS[:home] }
      new(actor: actor, **flags)
    end

    def onboarding_incomplete?
      @onboarding_incomplete
    end

    def show_activity?
      @show_activity
    end

    def never?
      false
    end

    def permit_metrics?
      @permit_metrics
    end

    PAGE_FLAGS = {
      home: { onboarding_incomplete: true, show_activity: true, permit_metrics: true },
      expanded: { onboarding_incomplete: false, show_activity: true, permit_metrics: true },
      restricted: { onboarding_incomplete: true, show_activity: true, permit_metrics: false, fail_if_loaded: true },
      cleared: { onboarding_incomplete: true, show_activity: false, permit_metrics: true }
    }.freeze
    private_constant :PAGE_FLAGS
  end
end
