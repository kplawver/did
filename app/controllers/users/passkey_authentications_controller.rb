module Users
  class PasskeyAuthenticationsController < ApplicationController
    def challenge
      options = WebAuthn::Credential.options_for_get(
        allow: PasskeyCredential.pluck(:external_id)
      )

      session[:webauthn_authentication_challenge] = options.challenge

      render json: options
    end

    def create
      webauthn_credential = WebAuthn::Credential.from_get(params[:credential])

      passkey = PasskeyCredential.find_by!(external_id: Base64.strict_encode64(webauthn_credential.raw_id))

      webauthn_credential.verify(
        session.delete(:webauthn_authentication_challenge),
        public_key: passkey.public_key,
        sign_count: passkey.sign_count
      )

      passkey.update!(
        sign_count: webauthn_credential.sign_count,
        last_used_at: Time.current
      )

      sign_in(passkey.user)
      render json: { redirect_to: root_path }
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Passkey not found" }, status: :unprocessable_entity
    end
  end
end
