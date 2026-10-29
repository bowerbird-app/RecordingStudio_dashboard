# frozen_string_literal: true

require "test_helper"

class ComposerTest < Minitest::Test
  class Probe
    def self.prepare(context, config)
      context.loaded << config[:name]
      raise "probe failed" if config[:boom]
      return RecordingStudioDashboard::Preparation.loading if config[:loading]
      return RecordingStudioDashboard::Preparation.empty(message: "none") if config[:value].nil?

      RecordingStudioDashboard::Preparation.content(config[:value], truncated: config.fetch(:truncated, false))
    end
  end

  class Context
    attr_reader :loaded

    def initialize(show_setup: true, allow_metrics: true)
      @show_setup = show_setup
      @allow_metrics = allow_metrics
      @loaded = []
    end

    def show_setup?
      @show_setup
    end

    def allow_metrics?
      @allow_metrics
    end
  end

  def setup
    RecordingStudioDashboard.reset!
    RecordingStudioDashboard.register_widget(
      :metric, component: Probe, default_span: 6, options: %i[name value loading boom truncated],
               permission: lambda(&:allow_metrics?)
    )
    RecordingStudioDashboard.register_widget(:setup, component: Probe, default_span: 6, options: %i[name value])
    @context = Context.new
  end

  def teardown
    RecordingStudioDashboard.reset!
  end

  def test_two_widget_types_share_a_row_and_keep_separate_config
    definition = register_home
    layout = compose(definition)

    row = layout.rows.first
    assert_equal %i[downloads setup], row.widgets.map(&:id)
    assert_equal [6, 6], row.widgets.map(&:span)
    assert_equal %w[downloads steps recent], @context.loaded
  end

  def test_a_collection_is_one_placement
    definition = register_home
    widget = compose(definition).rows[1].widgets.first

    assert_equal :recent, widget.id
    assert_equal :metric, widget.widget
    assert_equal [1, 2, 3], widget.preparation.data
  end

  def test_hidden_widget_expands_the_remaining_widget
    @context = Context.new(show_setup: false)
    row = compose(register_home).rows.first

    assert_equal [:downloads], row.widgets.map(&:id)
    assert_equal 12, row.widgets.first.span
    refute_includes @context.loaded, "steps"
  end

  def test_preserve_keeps_the_configured_span
    definition = RecordingStudioDashboard.register(:preserved) do
      row :studio, collapse: :preserve do
        widget :metric, id: :downloads, span: 6, config: { name: "downloads", value: 4 }
        widget :setup, id: :setup, span: 6, config: { name: "steps", value: "steps" }, visible_if: :show_setup?
      end
    end
    @context = Context.new(show_setup: false)
    widget = compose(definition).rows.first.widgets.first

    assert_equal 6, widget.span
  end

  def test_permission_skips_loading_and_removes_the_row_when_nothing_remains
    @context = Context.new(allow_metrics: false)
    layout = compose(register_home)

    assert_equal [:studio], layout.rows.map(&:id)
    assert_equal ["steps"], @context.loaded
  end

  def test_empty_hide_removes_the_widget_and_empty_message_keeps_it
    RecordingStudioDashboard.register_widget(:note, component: Probe, options: %i[name value], empty: :message,
                                                    empty_message: "Quiet")
    definition = RecordingStudioDashboard.register(:notes) do
      row :notes, title: "Notes" do
        widget :metric, id: :blank, span: 6, config: { name: "blank", value: nil }
        widget :note, id: :quiet, span: 6, config: { name: "quiet", value: nil }
      end
    end
    widgets = compose(definition).rows.first.widgets

    assert_equal [:quiet], widgets.map(&:id)
    assert_equal :empty, widgets.first.preparation.state
    assert_equal 12, widgets.first.span
  end

  def test_a_row_disappears_when_every_widget_is_hidden_unless_it_has_an_empty_state
    definition = RecordingStudioDashboard.register(:rows) do
      row :gone, title: "Gone" do
        widget :setup, visible_if: :show_setup?, config: { name: "steps", value: "steps" }
      end
      row :kept, title: "Kept", empty: { policy: :message, message: "Section is empty" } do
        widget :setup, id: :other, visible_if: :show_setup?, config: { name: "other", value: "other" }
      end
    end
    @context = Context.new(show_setup: false)
    layout = compose(definition)

    assert_equal [:kept], layout.rows.map(&:id)
    assert_empty layout.rows.first.widgets
    assert_equal :message, layout.rows.first.empty_state.policy
  end

  def test_one_widget_error_is_logged_and_does_not_drop_the_other_widget
    logger = Class.new do
      attr_reader :lines

      def initialize
        @lines = []
      end

      def error(message)
        @lines << message
      end
    end.new
    definition = RecordingStudioDashboard.register(:risky) do
      row :studio do
        widget :metric, id: :bad, config: { name: "bad", boom: true }
        widget :metric, id: :good, config: { name: "good", value: 1 }
      end
    end
    previous = Rails.logger
    Rails.logger = logger
    widgets = compose(definition).rows.first.widgets

    assert_equal %i[bad good], widgets.map(&:id)
    assert_equal :error, widgets.first.preparation.state
    assert_instance_of RuntimeError, widgets.first.preparation.error
    assert_equal :content, widgets.last.preparation.state
    assert_includes logger.lines.first, "probe failed"
  ensure
    Rails.logger = previous
  end

  def test_nil_is_not_treated_as_zero
    definition = RecordingStudioDashboard.register(:figures) do
      row :figures do
        widget :metric, id: :missing, config: { name: "missing", value: nil }
        widget :metric, id: :zero, config: { name: "zero", value: 0 }
      end
    end
    widgets = compose(definition).rows.first.widgets

    assert_equal [:zero], widgets.map(&:id)
    assert_equal 0, widgets.first.preparation.data
  end

  def test_fixed_policy_ignores_hide_overrides_and_personalised_policy_applies_them
    fixed = compose(register_home, RecordingStudioDashboard::Overrides.parse("hidden_placements" => ["setup"]))
    personal = RecordingStudioDashboard.register(:personal, policy: :personalised) do
      row :studio do
        widget :metric, id: :downloads, span: 6, mandatory: true, config: { name: "downloads", value: 4 }
        widget :setup, id: :setup, span: 6, config: { name: "steps", value: "steps" }
      end
    end
    hidden = compose(personal, RecordingStudioDashboard::Overrides.parse("hidden_placements" => %w[setup downloads]))

    assert_equal %i[downloads setup], fixed.rows.first.widgets.map(&:id)
    assert_equal [:downloads], hidden.rows.first.widgets.map(&:id)
    assert_equal 12, hidden.rows.first.widgets.first.span
  end

  def test_widget_type_can_be_placed_twice_with_isolated_config
    definition = RecordingStudioDashboard.register(:twice) do
      row :stats do
        widget :metric, id: :downloads, config: { name: "downloads", value: 4 }
        widget :metric, id: :views, config: { name: "views", value: 9 }
      end
    end
    widgets = compose(definition).rows.first.widgets

    assert_equal %i[downloads views], widgets.map(&:id)
    assert_equal %i[metric metric], widgets.map(&:widget)
    assert_equal([4, 9], widgets.map { |widget| widget.preparation.data })
  end

  def test_layout_hash_reuses_a_registered_widget_without_registering_a_new_dashboard
    definition = RecordingStudioDashboard.definition_from_layout(
      "board-1",
      { "rows" => [{ "id" => "saved", "title" => "Saved", "placements" => [
        { "id" => "saved_downloads", "widget" => "metric", "span" => 12,
          "config" => { "name" => "saved", "value" => 7 } }
      ] }] }
    )
    widget = compose(definition).rows.first.widgets.first

    assert_equal :saved_downloads, widget.id
    assert_equal 7, widget.preparation.data
    assert_raises(KeyError) { RecordingStudioDashboard.registry.dashboard("board-1") }
  end

  def test_widget_type_visible_if_skips_prepare
    RecordingStudioDashboard.reset!
    RecordingStudioDashboard.register_widget(
      :metric, component: Probe, default_span: 12, options: %i[name value], visible_if: :show_setup?
    )
    definition = RecordingStudioDashboard.register(:gated) do
      row :stats do
        widget :metric, id: :downloads, config: { name: "downloads", value: 4 }
      end
    end

    @context = Context.new(show_setup: false)
    assert_empty compose(definition).rows
    assert_empty @context.loaded

    @context = Context.new(show_setup: true)
    assert_equal [:downloads], compose(definition).rows.first.widgets.map(&:id)
    assert_equal ["downloads"], @context.loaded
  end

  def test_added_widget_uses_the_row_placement_order
    definition = RecordingStudioDashboard.register(:arranged, policy: :personalised) do
      row :stats do
        widget :metric, id: :downloads, span: 6, config: { name: "downloads", value: 4 }
        widget :metric, id: :views, span: 6, config: { name: "views", value: 9 }
      end
    end
    overrides = RecordingStudioDashboard::Overrides.parse(
      "placement_order" => { "stats" => %w[extra views downloads] },
      "added" => [{
        "id" => "extra", "widget" => "metric", "row" => "stats", "span" => 4,
        "config" => { "name" => "extra", "value" => 1 }
      }]
    )

    assert_equal %i[extra views downloads], compose(definition, overrides).rows.first.widgets.map(&:id)
  end

  def test_row_action_stays_when_a_widget_list_is_truncated
    definition = RecordingStudioDashboard.register(:truncated) do
      row :activity, title: "Recent activity", action: { label: "View all", url: "/all" } do
        widget :metric, id: :recent, config: { name: "recent", value: [1, 2], truncated: true }
      end
    end
    row = compose(definition).rows.first

    assert_equal "View all", row.action.label
    assert_equal "/all", row.action.url
  end

  def test_row_action_is_omitted_when_nothing_is_truncated
    definition = RecordingStudioDashboard.register(:short) do
      row :activity, title: "Recent activity", action: { label: "View all", url: "/all" } do
        widget :metric, id: :recent, config: { name: "recent", value: [1] }
      end
    end
    row = compose(definition).rows.first

    assert_nil row.action
    assert_equal "Recent activity", row.title
    assert_equal [1], row.widgets.first.preparation.data
  end

  def test_row_action_is_omitted_when_the_row_is_empty
    definition = RecordingStudioDashboard.register(:vacant) do
      row :activity, title: "Recent activity", action: { label: "View all", url: "/all" },
                     empty: { policy: :message, message: "Nothing yet" } do
        widget :metric, id: :recent, config: { name: "recent", value: nil }
      end
    end
    row = compose(definition).rows.first

    assert_nil row.action
    assert_equal "Recent activity", row.title
    assert_empty row.widgets
  end

  def test_overrides_store_only_the_delta
    overrides = RecordingStudioDashboard::Overrides.parse("hidden_placements" => ["setup"])

    assert_equal({ "hidden_placements" => ["setup"] }, overrides.to_h)
    refute overrides.to_h.key?("rows")
  end

  private

  def register_home
    RecordingStudioDashboard.register(:home) do
      row :studio, title: "Studio" do
        widget :metric, id: :downloads, span: 6, config: { name: "downloads", value: 4 }
        widget :setup, id: :setup, span: 6, config: { name: "steps", value: "steps" }, visible_if: :show_setup?
      end
      row :stats, title: "Stats" do
        widget :metric, id: :recent, span: 12, config: { name: "recent", value: [1, 2, 3] }
      end
    end
  end

  def compose(definition, overrides = RecordingStudioDashboard::Overrides.none)
    RecordingStudioDashboard::Composer.call(definition: definition, context: @context, overrides: overrides)
  end
end
