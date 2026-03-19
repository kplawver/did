FactoryBot.define do
  factory :passkey_credential do
    user
    external_id { SecureRandom.uuid }
    public_key { SecureRandom.hex(32) }
    nickname { "My Passkey" }
    sign_count { 0 }
    last_used_at { nil }
  end
end
