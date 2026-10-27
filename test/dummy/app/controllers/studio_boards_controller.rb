# frozen_string_literal: true

class StudioBoardsController < ApplicationController
  def show
    @board = StudioBoard.find(params[:id])
    @definition = RecordingStudioDashboard.definition_from_layout(@board.id, @board.layout, header: Demo::GreetingComponent)
    @context = Demo::DashboardContext.for(:home, current_user)
  end
end
