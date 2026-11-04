# frozen_string_literal: true

require "test_helper"

class DashboardEngineLayoutTest < ActionDispatch::IntegrationTest
  setup do
    @previous_layout = RecordingStudioDashboard.configuration.layout
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      mount RecordingStudioDashboard::Engine, at: "/recording_studio_dashboard"
    end
  end

  teardown do
    RecordingStudioDashboard.configuration.layout = @previous_layout
    Rails.application.routes.disable_clear_and_finalize = false
    Rails.application.reload_routes!
  end

  test "nil layout falls through to the Recording Studio default" do
    RecordingStudioDashboard.configuration.layout = nil

    get "/recording_studio_dashboard"

    assert_response :ok
    assert_equal RecordingStudio::DEFAULT_LAYOUT, @controller.recording_studio_resolved_layout
  end

  test "a named layout is used" do
    RecordingStudioDashboard.configuration.layout = "application"

    get "/recording_studio_dashboard"

    assert_response :ok
    assert_equal "application", @controller.recording_studio_resolved_layout
  end

  test "false skips a layout" do
    RecordingStudioDashboard.configuration.layout = false

    get "/recording_studio_dashboard"

    assert_response :ok
    assert_equal false, @controller.recording_studio_resolved_layout
  end
end
