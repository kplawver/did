require "rails_helper"

RSpec.describe "Passkey Registration", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /users/passkey_registrations/new" do
    it "returns WebAuthn creation options" do
      get new_users_passkey_registration_path, headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key("challenge")
      expect(json["user"]["name"]).to eq(user.email)
    end
  end

  describe "DELETE /users/passkey_registrations/:id" do
    it "removes a passkey credential" do
      credential = create(:passkey_credential, user: user)

      expect {
        delete users_passkey_registration_path(credential)
      }.to change(PasskeyCredential, :count).by(-1)

      expect(response).to redirect_to(edit_user_registration_path)
    end
  end
end
