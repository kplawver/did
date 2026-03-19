require "rails_helper"

RSpec.describe "Passkey Authentication", type: :request do
  describe "GET /users/passkey_authentication/challenge" do
    it "returns WebAuthn get options" do
      create(:passkey_credential)

      get challenge_users_passkey_authentication_path, headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key("challenge")
    end
  end
end
