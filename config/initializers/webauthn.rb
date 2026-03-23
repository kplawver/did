WebAuthn.configure do |config|
  app_host = ENV.fetch("APP_HOST", "localhost:3000")
  default_origin = Rails.env.production? ? "https://#{app_host}" : "http://#{app_host}"
  default_rp_id = app_host.split(":").first

  config.allowed_origins = [ ENV.fetch("WEBAUTHN_ORIGIN", default_origin) ]
  config.rp_name = "Did"
  config.rp_id = ENV.fetch("WEBAUTHN_RP_ID", default_rp_id)
end
