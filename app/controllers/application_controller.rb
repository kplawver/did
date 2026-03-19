class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_up_path_for(_resource)
    users_passkey_setup_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username ])
  end
end
