class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :allow_autoload

  def allow_autoload
    if devise_controller?
      @auto_load = false
      @devise_active = true
    else
      @devise_active = false
      @auto_load = true
    end
  end

end
