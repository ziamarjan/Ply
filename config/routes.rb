Ply::Application.routes.draw do

  def frame_resources
    match "/frame/:frame_name" => "frames#run_frame"

    match "/frame/:frame_name/templates" => "frames#templates_for_frame"
    match "/frame/:frame_name/services" => "frames#services_for_frame"
    match "/frame/:frame_name/info" => "frames#info"

    match "/frames/templates" => "frames#templates_for_frame"
    match "/frames/services" => "frames#services_for_frame"
    match "/frames/view" => "frames#run_frame"
    match "/frames/info" => "frames#info"
  end

  def root_resources
    match "/" => "root#index"

    match "/info/next_frame" => "root#next_frame"
  end

  root_resources
  frame_resources

end
