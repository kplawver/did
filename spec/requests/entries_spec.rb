require "rails_helper"

RSpec.describe "Entries", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user }

  describe "POST /entries" do
    it "creates an entry" do
      expect {
        post entries_path, params: { entry: { body: "Did some work", tag: "did", posted_on: Date.current } }, as: :turbo_stream
      }.to change(user.entries, :count).by(1)

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "renders markdown in body_html" do
      post entries_path, params: { entry: { body: "**bold** text", tag: "thought", posted_on: Date.current } }, as: :turbo_stream
      entry = user.entries.last
      expect(entry.body_html).to include("<strong>bold</strong>")
    end

    it "extracts hashtags and creates tags" do
      post entries_path, params: { entry: { body: "Working on #projectx", tag: "did", posted_on: Date.current } }, as: :turbo_stream
      entry = user.entries.last
      expect(entry.tags.pluck(:name)).to include("projectx")
      expect(Tag.find_by(name: "projectx")).to be_present
    end

    it "rejects blank body" do
      post entries_path, params: { entry: { body: "", tag: "did", posted_on: Date.current } }
      expect(response).to redirect_to(journal_path(Date.current))
    end
  end

  describe "DELETE /entries/:id" do
    let!(:entry) { create(:entry, user: user) }

    it "deletes the entry" do
      expect {
        delete entry_path(entry), as: :turbo_stream
      }.to change(user.entries, :count).by(-1)
    end
  end

  describe "authorization" do
    it "cannot delete another user's entry" do
      other_entry = create(:entry, user: other_user)
      delete entry_path(other_entry)
      expect(response).to have_http_status(:not_found)
    end
  end
end
