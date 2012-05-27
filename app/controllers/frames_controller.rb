class FramesController < ApplicationController

  before_filter :populate_frame, :only => [:run_frame, :services_for_frame, :templates_for_frame, :info]

  def populate_frame
    frame_target = (params[:frame_name].respond_to?(:to_sym) ? params[:frame_name].to_sym : nil)
    if frame_target.nil? && params[:app].present?
      frame_target = (params[:app][:currentFrame].to_sym rescue nil)
    end

    @no_layout = request.params[:layout].eql?("false")

    @frame = Ply::FrameServer::Base.frames[frame_target]

    raise ActionController::RoutingError.new('Not Found') if @frame.nil?

    @frame_name = @frame.name
  end

  def frame
    @frame
  end

  def run_frame
    instance_eval(&frame.main_block)

    @auto_load = false

    render "/#{frame.template_name}", :layout => !(@no_layout) ? true : false
  end

  def services_for_frame
    res = {}

    frame.supporting_services.each { |key, block_code| res[key] = instance_eval(&block_code) }

    respond_to do |format|
      format.json { render :json => res.to_json }
      format.xml { render :xml => res.to_xml(:root => :services) }
    end
  end

  def templates_for_frame
    @templates = frame.views

    render :templates_for_frame, :layout => false
  end

  def info
    res = {:frame_class_name => frame.name.to_s.classify, :update_every => frame.update_every, :show_for => frame.show_for}

    respond_to do |format|
      format.json { render :json => res.to_json }
      format.xml { render :xml => res.to_xml(:root => :services) }
    end    
  end
end