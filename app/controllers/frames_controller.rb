class FramesController < ApplicationController
  def run_frame
    frame_target = params[:frame_name].to_sym

    frame_holder = Ply::FrameServer::Base.frames[frame_target]

    instance_eval(&frame_holder.main_block)

    render frame_target
  end
end