Ply::Application.routes.draw do

  def frame_resources
    match "/frames/:frame_name" => "frames#run_frame"
    match "/frames/:frame_name/svc/:web_service" => "frames#run_frame"
    
    resources :frames, :as => :frames, :controller => :frames
  end

  def root_resources
    match "/" => "root#index"
  end

  root_resources
  frame_resources

end
