# frozen_string_literal: true

module RecordingStudioDashboard
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    recording_studio_layout { RecordingStudioDashboard.configuration.layout }
  end
end
