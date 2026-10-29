# frozen_string_literal: true

require "test_helper"

class PreparationTest < Minitest::Test
  def test_content_defaults_truncated_to_false
    preparation = RecordingStudioDashboard::Preparation.content([1, 2])

    assert_equal :content, preparation.state
    assert_equal [1, 2], preparation.data
    refute preparation.truncated?
  end

  def test_content_can_mark_a_list_truncated
    preparation = RecordingStudioDashboard::Preparation.content([1, 2], truncated: true)

    assert preparation.truncated?
    assert_equal [1, 2], preparation.data
  end

  def test_content_keyword_payload_still_works
    preparation = RecordingStudioDashboard::Preparation.content(items: [1], display: :grid, truncated: true)

    assert_equal({ items: [1], display: :grid }, preparation.data)
    assert preparation.truncated?
  end

  def test_empty_loading_and_error_are_never_truncated
    refute RecordingStudioDashboard::Preparation.empty.truncated?
    refute RecordingStudioDashboard::Preparation.loading.truncated?
    refute RecordingStudioDashboard::Preparation.error(RuntimeError.new("boom")).truncated?
  end
end
