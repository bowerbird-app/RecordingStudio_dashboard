# frozen_string_literal: true

module RecordingStudioDashboard
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    recording_studio_layout do
      setting = RecordingStudioDashboard.configuration.layout
      setting.nil? ? RecordingStudio::DEFAULT_LAYOUT : setting
    end
  end
end
