require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:passkey_credentials).dependent(:destroy) }
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
end
