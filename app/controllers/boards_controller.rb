class BoardsController < ApplicationController

  before_filter :populate_board, :only => [:run_board, :services_for_board, :templates_for_board, :info]

  def populate_board
    board_target = (params[:board_name].respond_to?(:to_sym) ? params[:board_name].to_sym : nil)
    if board_target.nil? && params[:app].present?
      board_target = (params[:app][:currentBoard].to_sym rescue nil)
    end

    @no_layout = request.params[:layout].eql?("false")

    @board = Ply::BoardServer::Base.boards[board_target]

    raise ActionController::RoutingError.new('Not Found') if @board.nil?

    @board_name = @board.name
  end

  def board
    @board
  end

  def run_board
    instance_eval(&board.main_block)

    @auto_load = false

    render "/#{board.template_name}", :layout => !(@no_layout) ? true : false
  end

  def services_for_board
    res = {}

    board.supporting_services.each { |key, block_code| res[key] = instance_eval(&block_code) }

    respond_to do |format|
      format.json { render :json => res.to_json }
      format.xml { render :xml => res.to_xml(:root => :services) }
    end
  end

  def templates_for_board
    @templates = board.views

    render :templates_for_board, :layout => false
  end

  def info
    res = {:board_class_name => board.name.to_s.classify, :update_every => board.update_every, :show_for => board.show_for}

    respond_to do |format|
      format.json { render :json => res.to_json }
      format.xml { render :xml => res.to_xml(:root => :services) }
    end    
  end
end