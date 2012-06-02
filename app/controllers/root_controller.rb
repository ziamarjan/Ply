class RootController < ApplicationController
  def index
    
  end

  def next_board

    application_view_model = params[:app] || {}

    current_board = application_view_model[:currentBoard]
    Rails.logger.debug("Received information from App view model, current board is #{current_board}")
    next_board_name = Ply::BoardServer::Base.next_board(current_board, :user => current_user)
    res = {:next_board => next_board_name, :board_class_name => next_board_name.to_s.classify}

    respond_to do |format|
      format.json { render :json => res.to_json(:root => :response) }
      format.xml { render :xml => res.to_xml(:root => :response) }
    end
  end
end