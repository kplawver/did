require "rails_helper"

RSpec.describe "Password Reset", type: :request do
  let(:user) { create(:user) }

  describe "POST /users/password" do
    it "sends reset instructions" do
      post user_password_path, params: {
        user: { email: user.email }
      }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "PUT /users/password" do
    it "resets password with valid token" do
      token = user.send_reset_password_instructions

      put user_password_path, params: {
        user: {
          reset_password_token: token,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      expect(response).to redirect_to(root_path)
    end
  end
end
