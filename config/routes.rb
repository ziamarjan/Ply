Ply::Application.routes.draw do

  def frame_resources
    match "/frames/:frame_name" => "frames#run_frame"

    match "/frames/:frame_name/services" => "frames#services_for_frame" 
  end

  def root_resources
    match "/" => "root#index"

    match "/info/next_frame" => "root#next_frame"
  end

  root_resources
  frame_resources

end
