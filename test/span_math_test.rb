# frozen_string_literal: true

require "test_helper"
require "view_component"
require File.expand_path("../app/components/recording_studio_dashboard/widget_frame_component", __dir__)

class SpanMathTest < Minitest::Test
  def test_span_six_is_full_width_at_base
    assert_equal({ base: 2, md: 2, lg: 6 }, RecordingStudioDashboard::WidgetFrameComponent.item_span(6))
  end

  def test_span_three_stays_one_track_at_base
    assert_equal({ base: 1, md: 1, lg: 3 }, RecordingStudioDashboard::WidgetFrameComponent.item_span(3))
  end

  def test_span_utilities_include_desktop_half_width
    assert_includes RecordingStudioDashboard::WidgetFrameComponent::GRID_UTILITIES, "lg:col-span-6"
    assert_includes RecordingStudioDashboard::WidgetFrameComponent::GRID_UTILITIES, "lg:grid-cols-12"
  end

  def test_span_twelve_is_unchanged
    assert_equal({ base: 2, md: 4, lg: 12 }, RecordingStudioDashboard::WidgetFrameComponent.item_span(12))
  end

  def test_span_four_and_five_are_full_width_at_base
    assert_equal({ base: 2, md: 2, lg: 4 }, RecordingStudioDashboard::WidgetFrameComponent.item_span(4))
    assert_equal({ base: 2, md: 2, lg: 5 }, RecordingStudioDashboard::WidgetFrameComponent.item_span(5))
  end

  def test_valid_hash_passes_through_item_span
    hash = { base: 2, lg: 6 }

    assert_same hash, RecordingStudioDashboard::WidgetFrameComponent.item_span(hash)
  end

  def test_layout_width_prefers_lg_then_largest
    assert_equal 6, RecordingStudioDashboard::SpanMath.layout_width(6)
    assert_equal 6, RecordingStudioDashboard::SpanMath.layout_width({ base: 2, lg: 6 })
    assert_equal 4, RecordingStudioDashboard::SpanMath.layout_width({ base: 2, md: 4 })
  end

  def test_coerce_accepts_a_valid_hash
    assert_equal({ base: 2, lg: 6 }, RecordingStudioDashboard::SpanMath.coerce({ "base" => 2, "lg" => 6 }))
  end

  def test_invalid_hash_key_raises
    error = assert_raises(ArgumentError) { RecordingStudioDashboard::SpanMath.coerce({ base: 2, xs: 1 }) }

    assert_match(/invalid span breakpoints: xs/, error.message)
  end

  def test_empty_hash_raises
    error = assert_raises(ArgumentError) { RecordingStudioDashboard::SpanMath.coerce({}) }

    assert_match(/span hash cannot be empty/, error.message)
  end

  def test_invalid_hash_value_raises
    error = assert_raises(ArgumentError) { RecordingStudioDashboard::SpanMath.coerce({ base: 3 }) }

    assert_match(/invalid span base: 3/, error.message)
  end

  def test_expand_keeps_hashes_that_already_fill_the_row
    spans = [{ base: 2, lg: 6 }, { base: 2, lg: 6 }]

    assert_equal spans, RecordingStudioDashboard::SpanMath.effective(spans, :expand)
  end

  def test_expand_turns_a_short_hash_into_an_integer
    assert_equal [12], RecordingStudioDashboard::SpanMath.effective([{ base: 2, lg: 6 }], :expand)
  end
end
