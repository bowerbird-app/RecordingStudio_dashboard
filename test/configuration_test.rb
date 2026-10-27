# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @configuration = RecordingStudioDashboard::Configuration.new
  end

  def test_merge_ignores_unknown_keys
    @configuration.merge!(unknown_key: "ignored")

    refute_respond_to @configuration, :unknown_key
    assert_instance_of RecordingStudio::Hooks, @configuration.hooks
  end

  def test_merge_with_non_enumerable_is_noop
    original = @configuration.to_h

    @configuration.merge!(nil)

    assert_equal original[:hooks_registered], @configuration.to_h[:hooks_registered]
  end

  def test_initialize_uses_recording_studio_hooks
    assert_instance_of RecordingStudio::Hooks, @configuration.hooks
    refute_respond_to @configuration, :api_key
  end

  def test_merge_accepts_string_keys_for_unknown_values
    @configuration.merge!("unknown_key" => "string-key")

    refute_respond_to @configuration, :unknown_key
  end

  def test_to_h_reports_registered_hook_counts
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.before_initialize { nil }
    @configuration.hooks.after_service { nil }

    result = @configuration.to_h

    assert_equal 2, result.fetch(:hooks_registered).fetch(:before_initialize)
    assert_equal 1, result.fetch(:hooks_registered).fetch(:after_service)
  end

  def test_configure_without_block_is_safe
    RecordingStudioDashboard.configure

    assert_kind_of RecordingStudioDashboard::Configuration, RecordingStudioDashboard.configuration
  end
end
