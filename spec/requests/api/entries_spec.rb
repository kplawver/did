require "rails_helper"

RSpec.describe "Api::Entries", type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { "Authorization" => "Bearer #{user.api_token}" } }

  before { user.regenerate_api_token }

  describe "GET /api/entries" do
    context "without authentication" do
      it "returns 401" do
        get api_entries_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid token" do
      it "returns all entries" do
        create_list(:entry, 3, user: user)

        get api_entries_path, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["entries"].size).to eq(3)
      end

      it "filters by date" do
        create(:entry, user: user, posted_on: Date.current)
        create(:entry, user: user, posted_on: Date.current - 1)

        get api_entries_path, params: { date: Date.current.to_s }, headers: auth_headers
        expect(response.parsed_body["entries"].size).to eq(1)
      end

      it "filters by date range" do
        create(:entry, user: user, posted_on: Date.current)
        create(:entry, user: user, posted_on: Date.current - 5)
        create(:entry, user: user, posted_on: Date.current - 10)

        get api_entries_path, params: { from: (Date.current - 6).to_s, to: Date.current.to_s }, headers: auth_headers
        expect(response.parsed_body["entries"].size).to eq(2)
      end

      it "filters by tag" do
        create(:entry, user: user, tag: :did)
        create(:entry, user: user, tag: :win)

        get api_entries_path, params: { tag: "did" }, headers: auth_headers
        expect(response.parsed_body["entries"].size).to eq(1)
        expect(response.parsed_body["entries"].first["tag"]).to eq("did")
      end

      it "returns 422 for invalid date" do
        get api_entries_path, params: { date: "not-a-date" }, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /api/entries/search" do
    context "with valid token" do
      it "searches entry bodies" do
        create(:entry, user: user, body: "Worked on the authentication module")
        create(:entry, user: user, body: "Had lunch with the team")

        get search_api_entries_path, params: { q: "authentication" }, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["entries"].size).to eq(1)
        expect(response.parsed_body["query"]).to eq("authentication")
      end

      it "returns empty results for no matches" do
        create(:entry, user: user, body: "Regular entry")

        get search_api_entries_path, params: { q: "nonexistent" }, headers: auth_headers
        expect(response.parsed_body["entries"]).to be_empty
      end

      it "returns 422 when query is missing" do
        get search_api_entries_path, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not return other users' entries" do
        other_user = create(:user)
        create(:entry, user: other_user, body: "Secret entry about authentication")

        get search_api_entries_path, params: { q: "authentication" }, headers: auth_headers
        expect(response.parsed_body["entries"]).to be_empty
      end
    end
  end
end
