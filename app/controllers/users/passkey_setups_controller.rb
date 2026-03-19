class Users::PasskeySetupsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def skip
    current_user.update(passkey_setup_prompted: true)
    redirect_to authenticated_root_path
  end
end
