require "rails_helper"

RSpec.describe "User Registration", type: :request do
  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          username: "testuser",
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "creates a new user with valid params" do
      expect {
        post user_registration_path, params: valid_params
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
    end

    it "fails without a username" do
      post user_registration_path, params: {
        user: valid_params[:user].merge(username: "")
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(User.count).to eq(0)
    end

    it "fails with a duplicate email" do
      create(:user, email: "test@example.com")

      post user_registration_path, params: valid_params

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "fails with a duplicate username" do
      create(:user, username: "testuser")

      post user_registration_path, params: valid_params

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
