# frozen_string_literal: true

require "test_helper"

class DashboardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.find_or_create_by!(email: "dashboard@example.com") do |user|
      user.password = "Password"
      user.password_confirmation = "Password"
    end
    sign_in @user
    load Rails.root.join("db/seeds.rb").to_s
  end

  test "home renders one collection widget beside other widget types" do
    get root_path

    assert_response :success
    assert_select "[data-dashboard=home]"
    assert_select "[data-dashboard-row=studio] [data-dashboard-placement]", count: 2
    assert_select "[data-dashboard-placement=recent_items] [data-collection-item]", count: 3
    assert_select "[data-dashboard-placement=downloads]"
    assert_select "[data-dashboard-placement=views]"
    assert_includes response.body, "Spring release"
    refute_includes response.body, "Radio session"
    refute_includes response.body, "Two different widgets share this row."
    refute_includes response.body, "One widget owns every card inside it."
    assert_select "[data-dashboard-row=studio] .fp-section-title.fp-on-backdrop.mb-0"
    assert_select "[data-dashboard-row=activity] [data-fp-style=default]", text: /View all/
    assert_select "[data-dashboard-row=studio].gap-3"
    assert_select "[data-dashboard-placement=overview] .fp-section-title h3", text: "Studio overview"
    assert_select "[data-dashboard-placement=checklist] .fp-section-title h3", text: "Getting started"
    assert_select "[data-dashboard-placement=downloads] .fp-section-title h3", text: "Downloads"
    assert_select "[data-dashboard-placement=recent_items] .fp-section-title h3", text: "Spring release"
    assert_select "[data-dashboard-placement=overview] .border-b", count: 0
    assert_select "[data-dashboard-placement=checklist] .border-b", count: 0
    assert_select "[data-dashboard-placement=recent_items] .border-b", count: 0
    assert_select "[data-dashboard-placement=downloads] .border-b", count: 0
    assert_select ".fp-card.fp-on-backdrop", count: 0
    assert_background_image
    assert_backdrop_page_text
  end

  test "carousel reuses the collection widget with isolated config" do
    get dashboard_path("carousel")

    assert_response :success
    assert_select "[data-dashboard=carousel] [data-dashboard-placement=recent_items]", count: 1
    assert_includes response.body, "Radio session"
    assert_select "[data-dashboard=carousel] .flat-pack-carousel"
    assert_select "[data-dashboard=carousel] [data-dashboard-placement=recent_items] .fp-section-title h3",
                  text: "Radio session"
    refute_includes response.body, "configured as a carousel."
    assert_select "[data-dashboard-placement=carousel_views]", text: /0/
    assert_backdrop_page_text
  end

  test "a hidden checklist expands the overview" do
    get dashboard_path("expanded")

    assert_response :success
    assert_select "[data-dashboard-placement=overview][data-dashboard-span=12]"
    assert_select "[data-dashboard-placement=checklist]", count: 0
    refute_includes response.body, "Getting started"
    assert_backdrop_page_text
  end

  test "empty policies hide rows and keep an explicit section message" do
    get dashboard_path("empty")

    assert_response :success
    refute_includes response.body, "Seasonal notes"
    refute_includes response.body, "Cleared row"
    assert_includes response.body, "Needs content"
    assert_includes response.body, "No recent items yet"
    assert_select "[data-dashboard-placement=empty_items][data-dashboard-state=empty]"
    assert_backdrop_page_text
  end

  test "restricted metrics are not loaded" do
    get dashboard_path("restricted")

    assert_response :success
    assert_select "[data-dashboard-placement=overview]"
    assert_select "[data-dashboard-placement=downloads]", count: 0
    refute_includes response.body, "loaded without permission"
    refute_includes response.body, "This widget could not be displayed."
    assert_backdrop_page_text
  end

  test "personalised mode stores a hide override and expands the mandatory widget" do
    get dashboard_path("personalised")

    assert_response :success
    assert_select "[data-dashboard-placement=overview][data-dashboard-span=12]"
    assert_select "[data-dashboard-placement=checklist]", count: 0
    stored = RecordingStudioDashboard::Preference.find_by!(
      dashboard_key: "personalised",
      actor_type: @user.class.name,
      actor_id: @user.id
    )
    assert_equal ["checklist"], stored.overrides["hidden_placements"]
    refute stored.overrides.key?("rows")
    assert_backdrop_page_text
  end

  test "a saved board recording renders through the same composition" do
    board = StudioBoard.find_by!(name: "My board")

    get studio_board_path(board)

    assert_response :success
    assert_select "[data-dashboard-placement=saved_downloads]"
    assert_select "[data-dashboard-placement=saved_items] [data-collection-item]", count: 2
    assert_includes response.body, "Saves"
    refute_includes response.body, "Radio session"
    assert_background_image
    assert_backdrop_page_text
  end

  private

  def assert_backdrop_page_text
    assert_select "[data-dashboard] > .fp-on-backdrop h1"
    assert_select "[data-dashboard] .fp-on-backdrop h1"
    assert_select ".fp-on-backdrop [data-dashboard-placement]", count: 0
    assert_select "[data-dashboard-row] .fp-section-title.fp-on-backdrop"
    assert_select "nav.flat-pack-page-nav"
    assert_select "nav.flat-pack-page-nav.fp-on-backdrop", count: 0
    assert_select "nav.flat-pack-page-nav [data-fp-style=default]"
    assert_select "a[data-turbo-method=delete][data-fp-style=default]", text: "Sign out"
    assert_select "[data-dashboard-row] [data-fp-style=ghost]", count: 0
    assert_select ".fp-on-backdrop [data-fp-style=default]", count: 0
    assert_select "a", text: "Personalised", count: 0
  end

  def assert_background_image
    assert_select "[data-recording-studio-default-layout=true] [data-flat-pack-layout-background=true]", count: 1
    assert_select ".fp-backdrop-media img[alt=''][loading='lazy'][src*='dashboard-backdrop']", count: 1
    assert_select ".fp-backdrop-tint", count: 1
  end
end
