class FramesController < ApplicationController

  before_filter :populate_frame, :only => [:run_frame, :services_for_frame]

  def populate_frame
    frame_target = params[:frame_name].to_sym

    @frame = Ply::FrameServer::Base.frames[frame_target]

    raise ActionController::RoutingError.new('Not Found') if @frame.nil?
  end

  def frame
    @frame
  end

  def run_frame
    instance_eval(&frame.main_block)

    render frame.template_name
  end

  def services_for_frame
    res = {}

    frame.supporting_services.each { |key, block_code| res[key] = instance_eval(&block_code) }

    respond_to do |format|
      format.json { render :json => res.to_json }
      format.xml { render :xml => res.to_xml(:root => :services) }
    end
  end
end