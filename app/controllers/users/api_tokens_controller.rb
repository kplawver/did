class Users::ApiTokensController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.regenerate_api_token
    redirect_to edit_user_registration_path, notice: "API token generated."
  end

  def destroy
    current_user.update!(api_token: nil)
    redirect_to edit_user_registration_path, notice: "API token revoked."
  end
end
