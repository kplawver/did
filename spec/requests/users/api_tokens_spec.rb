require "rails_helper"

RSpec.describe "Users::ApiTokens", type: :request do
  let(:user) { create(:user) }

  describe "POST /users/api_token" do
    context "when not authenticated" do
      it "redirects to sign in" do
        post users_api_token_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "generates an API token" do
        expect { post users_api_token_path }.to change { user.reload.api_token }.from(nil)
        expect(response).to redirect_to(edit_user_registration_path)
      end

      it "regenerates an existing token" do
        user.regenerate_api_token
        old_token = user.api_token

        post users_api_token_path
        expect(user.reload.api_token).not_to eq(old_token)
      end
    end
  end

  describe "DELETE /users/api_token" do
    context "when authenticated" do
      before do
        sign_in user
        user.regenerate_api_token
      end

      it "revokes the API token" do
        expect { delete users_api_token_path }.to change { user.reload.api_token }.to(nil)
        expect(response).to redirect_to(edit_user_registration_path)
      end
    end
  end
end
