Ply::Application.routes.draw do

  devise_for :users

  def board_resources
    match "/board/:board_name" => "boards#run_board"

    match "/board/:board_name/templates" => "boards#templates_for_board"
    match "/board/:board_name/services" => "boards#services_for_board"
    match "/board/:board_name/info" => "boards#info"

    match "/boards/templates" => "boards#templates_for_board"
    match "/boards/services" => "boards#services_for_board"
    match "/boards/view" => "boards#run_board"
    match "/boards/info" => "boards#info"
  end

  def root_resources
    root :to => "root#index"

    match "/info/next_board" => "root#next_board"
  end

  root_resources
  board_resources

end
