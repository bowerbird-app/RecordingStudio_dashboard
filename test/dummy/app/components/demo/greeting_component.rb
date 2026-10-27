# frozen_string_literal: true

module Demo
  class GreetingComponent < ViewComponent::Base
    def initialize(context:)
      @context = context
    end

    def call
      render FlatPack::PageTitle::Component.new(
        title: greeting,
        subtitle: "Your studio dashboard",
        variant: :h1,
        class: "fp-on-backdrop"
      )
    end

    private

    def greeting
      "#{salutation}, #{@context.name}"
    end

    def salutation
      hour = Time.zone.now.hour
      return "Good morning" if hour < 12
      return "Good afternoon" if hour < 17

      "Good evening"
    end
  end
end
