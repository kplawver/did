require "rails_helper"

RSpec.describe "Api::Journal", type: :request do
  let(:user) { create(:user) }
  let(:headers) { {} }

  before { user.regenerate_api_token }

  let(:auth_headers) { { "Authorization" => "Bearer #{user.api_token}" } }

  describe "GET /api/journal/:date" do
    context "without authentication" do
      it "returns 401" do
        get api_journal_path(date: Date.current.to_s)
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token" do
      it "returns 401" do
        get api_journal_path(date: Date.current.to_s), headers: { "Authorization" => "Bearer invalid" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid token" do
      it "returns today's journal" do
        todo = create(:todo_item, user: user, due_date: Date.current)
        entry = create(:entry, user: user, posted_on: Date.current, tag: :did)

        get api_journal_path(date: Date.current.to_s), headers: auth_headers
        expect(response).to have_http_status(:ok)

        body = response.parsed_body
        expect(body["date"]).to eq(Date.current.to_s)
        expect(body["is_today"]).to be true
        expect(body["todo_items"].size).to eq(1)
        expect(body["todo_items"].first["title"]).to eq(todo.title)
        expect(body["entries"].size).to eq(1)
        expect(body["entries"].first["body"]).to eq(entry.body)
      end

      it "returns summary with counts" do
        create(:todo_item, user: user, due_date: Date.current, completed: true, completed_at: Time.current)
        create(:todo_item, user: user, due_date: Date.current)
        create(:entry, user: user, posted_on: Date.current, tag: :did)
        create(:entry, user: user, posted_on: Date.current, tag: :win)

        get api_journal_path(date: Date.current.to_s), headers: auth_headers

        summary = response.parsed_body["summary"]
        expect(summary["total_todos"]).to eq(2)
        expect(summary["completed_todos"]).to eq(1)
        expect(summary["incomplete_todos"]).to eq(1)
        expect(summary["entry_count"]).to eq(2)
        expect(summary["entry_tags"]).to include("did" => 1, "win" => 1)
      end

      it "includes tag names for todos" do
        tag = create(:tag, name: "projectx")
        todo = create(:todo_item, user: user, due_date: Date.current, title: "Fix #projectx bug")

        get api_journal_path(date: Date.current.to_s), headers: auth_headers

        todo_data = response.parsed_body["todo_items"].first
        expect(todo_data["tags"]).to include("projectx")
      end

      it "shows rolled over status" do
        todo = create(:todo_item, user: user, due_date: Date.current - 3)
        todo.update_column(:due_date, Date.current)

        get api_journal_path(date: Date.current.to_s), headers: auth_headers

        todo_data = response.parsed_body["todo_items"].first
        expect(todo_data["rolled_over"]).to be true
        expect(todo_data["original_due_date"]).to eq((Date.current - 3).to_s)
      end

      it "does not leak other users' data" do
        other_user = create(:user)
        create(:todo_item, user: other_user, due_date: Date.current)

        get api_journal_path(date: Date.current.to_s), headers: auth_headers

        expect(response.parsed_body["todo_items"]).to be_empty
      end
    end
  end
end
