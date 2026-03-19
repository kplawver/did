require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:passkey_credentials).dependent(:destroy) }
    it { is_expected.to have_many(:todo_items).dependent(:destroy) }
    it { is_expected.to have_many(:entries).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(30) }

    it "validates username format allows alphanumeric and underscores" do
      user = build(:user, username: "valid_user_1")
      expect(user).to be_valid
    end

    it "rejects usernames with special characters" do
      user = build(:user, username: "invalid-user!")
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("only allows letters, numbers, and underscores")
    end

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe "webauthn_id" do
    it "generates a webauthn_id on create" do
      user = create(:user)
      expect(user.webauthn_id).to be_present
    end
  end

  describe "api_token" do
    it "does not generate a token on create" do
      user = create(:user)
      expect(user.api_token).to be_nil
    end

    it "generates a unique token on demand" do
      user = create(:user)
      user.regenerate_api_token
      expect(user.api_token).to be_present
      expect(user.api_token.length).to be >= 24
    end

    it "regenerates a different token each time" do
      user = create(:user)
      user.regenerate_api_token
      first_token = user.api_token

      user.regenerate_api_token
      expect(user.api_token).not_to eq(first_token)
    end

    it "can be revoked by setting to nil" do
      user = create(:user)
      user.regenerate_api_token
      expect(user.api_token).to be_present

      user.update!(api_token: nil)
      expect(user.api_token).to be_nil
    end
  end
end
