class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :allow_autoload, :auto_logon

  def allow_autoload
    if devise_controller?
      @auto_load = false
      @devise_active = true
    else
      @devise_active = false
      @auto_load = true
    end
  end

  def auto_logon
    if !(devise_controller?) && current_user.nil?
      auto_user = User.any_in(:auto_login_from_ips => request.ip).first
      sign_in(auto_user) unless auto_user.nil?
    end
  end

end
