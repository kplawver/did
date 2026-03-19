require "rails_helper"

RSpec.describe "User Sessions", type: :request do
  let(:user) { create(:user, password: "password123") }

  describe "POST /users/sign_in" do
    it "signs in with valid credentials" do
      post user_session_path, params: {
        user: { email: user.email, password: "password123" }
      }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include(user.username)
    end

    it "fails with wrong password" do
      post user_session_path, params: {
        user: { email: user.email, password: "wrongpassword" }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "locks account after maximum failed attempts" do
      11.times do
        post user_session_path, params: {
          user: { email: user.email, password: "wrongpassword" }
        }
      end

      user.reload
      expect(user.access_locked?).to be true
    end
  end

  describe "DELETE /users/sign_out" do
    it "signs out the user" do
      sign_in user

      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
    end
  end
end
