module WebAuthnTestHelpers
  def fake_webauthn_credential
    credential = WebAuthn::FakeClient.new("http://localhost:3000").create
    credential
  end

  def fake_client
    WebAuthn::FakeClient.new("http://localhost:3000")
  end
end

RSpec.configure do |config|
  config.include WebAuthnTestHelpers, type: :request
end
