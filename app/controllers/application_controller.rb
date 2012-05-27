class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :allow_autoload

  def allow_autoload
    @auto_load = true
  end

end
