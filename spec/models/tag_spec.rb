require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:tag) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe "name normalization" do
    it "downcases and strips the name" do
      tag = create(:tag, name: "  ProjectX  ")
      expect(tag.name).to eq("projectx")
    end
  end
end
