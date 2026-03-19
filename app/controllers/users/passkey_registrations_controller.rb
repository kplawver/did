module Users
  class PasskeyRegistrationsController < ApplicationController
    before_action :authenticate_user!

    def new
      options = WebAuthn::Credential.options_for_create(
        user: {
          id: current_user.webauthn_id,
          name: current_user.email,
          display_name: current_user.username
        },
        exclude: current_user.passkey_credentials.pluck(:external_id)
      )

      session[:webauthn_registration_challenge] = options.challenge

      render json: options
    end

    def create
      webauthn_credential = WebAuthn::Credential.from_create(params[:credential])

      webauthn_credential.verify(session.delete(:webauthn_registration_challenge))

      current_user.passkey_credentials.create!(
        external_id: Base64.strict_encode64(webauthn_credential.raw_id),
        public_key: webauthn_credential.public_key,
        nickname: params[:nickname].presence || "Passkey",
        sign_count: webauthn_credential.sign_count
      )

      render json: { status: "ok" }, status: :created
    rescue WebAuthn::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def destroy
      credential = current_user.passkey_credentials.find(params[:id])
      credential.destroy!
      redirect_to edit_user_registration_path, notice: "Passkey removed."
    end
  end
end
