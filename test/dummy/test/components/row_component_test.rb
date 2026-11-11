# frozen_string_literal: true

require "test_helper"

class RowComponentTest < ViewComponent::TestCase
  test "heading renders when the row has only custom buttons" do
    doc = render_row(title: nil, action: nil, buttons: [button("New", "/new")])

    assert_equal ["New"], labels(doc)
    assert_empty doc.css("[data-dashboard-row=notes] .fp-section-title")
    assert_empty doc.css("[data-dashboard-row=notes] .fp-on-backdrop [data-fp-style=default]")
  end

  test "custom buttons render before the view more action" do
    doc = render_row(
      title: "Recent activity",
      action: RecordingStudioDashboard::HeadingAction.new(label: "View all", url: "/all"),
      buttons: [
        button("New", "/new", icon: "plus", method: :post),
        button("Edit", "/edit")
      ]
    )

    assert_equal ["New", "Edit", "View all"], labels(doc)
    link = doc.at_css("[data-dashboard-row=notes] a[href='/new'][data-method=post]")
    assert link
    assert_equal "plus", link.at_css("svg")["data-flat-pack--icon-name-value"]
    assert_equal "Recent activity", doc.at_css("[data-dashboard-row=notes] .fp-section-title.fp-on-backdrop").text.squish
    assert_empty doc.css("[data-dashboard-row=notes] .fp-on-backdrop [data-fp-style=default]")
  end

  private

  def render_row(...)
    render_inline(component(...))
    Nokogiri::HTML.fragment(rendered_content)
  end

  def labels(doc)
    doc.css("[data-dashboard-row=notes] a[data-fp-style=default]").map { |node| node.text.squish }
  end

  def component(title:, action:, buttons:)
    row = RecordingStudioDashboard::LaidRow.new(
      id: :notes,
      title: title,
      description: nil,
      action: action,
      buttons: buttons,
      spacing: :lg,
      widgets: [],
      empty_state: RecordingStudioDashboard::EmptyState.hide
    )
    RecordingStudioDashboard::RowComponent.new(row: row, context: Object.new)
  end

  def button(label, url, icon: nil, method: nil)
    RecordingStudioDashboard::HeadingButton.new(
      label: label, url: url, icon: icon, http_method: method, visible_if: nil
    )
  end
end
