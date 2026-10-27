# frozen_string_literal: true

class DashboardsController < ApplicationController
  PAGES = {
    home: :home,
    carousel: :carousel,
    expanded: :home,
    empty: :empty,
    personalised: :personalised,
    restricted: :home
  }.freeze

  def show
    page = params[:id].to_sym
    @definition_id = PAGES.fetch(page) { raise ActiveRecord::RecordNotFound }
    remember_personalisation(page)
    @context = Demo::DashboardContext.for(page, current_user)
    @board = StudioBoard.find_by(name: "My board")
  end

  private

  def remember_personalisation(page)
    return unless page == :personalised

    RecordingStudioDashboard::Preference.store!(
      dashboard_key: :personalised,
      actor: current_user,
      overrides: { "hidden_placements" => ["checklist"] }
    )
  end
end
