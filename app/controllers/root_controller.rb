class RootController < ApplicationController
  def index
    
  end

  def next_frame

    application_view_model = params[:app] || {}

    current_frame = application_view_model[:currentFrame]
    Rails.logger.debug("Received information from App view model, current frame is #{current_frame}")
    next_frame_name = Ply::FrameServer::Base.next_frame(current_frame)
    res = {:next_frame => next_frame_name, :frame_class_name => next_frame_name.to_s.classify}

    respond_to do |format|
      format.json { render :json => res.to_json(:root => :response) }
      format.xml { render :xml => res.to_xml(:root => :response) }
    end
  end
end