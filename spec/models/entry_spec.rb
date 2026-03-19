require "rails_helper"

RSpec.describe Entry, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:taggings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:posted_on) }
  end

  describe "enum" do
    it { is_expected.to define_enum_for(:tag).with_values(did: 0, thought: 1, idea: 2, win: 3, emotion: 4) }
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".for_date" do
      it "returns entries for a specific date" do
        today = create(:entry, user: user, posted_on: Date.current)
        create(:entry, user: user, posted_on: Date.current - 1)
        expect(described_class.for_date(Date.current)).to eq([ today ])
      end
    end

    describe ".by_tag" do
      it "filters by tag type" do
        thought = create(:entry, user: user, tag: :thought)
        create(:entry, user: user, tag: :did)
        expect(described_class.by_tag(:thought)).to eq([ thought ])
      end
    end

    describe ".chronological" do
      it "orders by created_at" do
        first = create(:entry, user: user)
        second = create(:entry, user: user)
        expect(described_class.chronological).to eq([ first, second ])
      end
    end
  end

  describe "markdown rendering" do
    it "renders body as HTML in body_html" do
      entry = create(:entry, body: "**bold** text")
      expect(entry.body_html).to include("<strong>bold</strong>")
    end

    it "renders autolinks" do
      entry = create(:entry, body: "Check https://example.com")
      expect(entry.body_html).to include('href="https://example.com"')
    end
  end

  describe "hashtag extraction" do
    it "extracts hashtags from body and creates tags" do
      entry = create(:entry, body: "Working on #projectX and #backend today")
      expect(entry.tags.pluck(:name)).to match_array(%w[projectx backend])
    end

    it "does not create tags for entry enum names" do
      entry = create(:entry, body: "This is a #did and a #thought")
      expect(entry.tags.pluck(:name)).to be_empty
    end

    it "does not create duplicate tags" do
      create(:tag, name: "projectx")
      entry = create(:entry, body: "More work on #projectX")
      expect(Tag.where(name: "projectx").count).to eq(1)
      expect(entry.tags.pluck(:name)).to eq(%w[projectx])
    end
  end
end
