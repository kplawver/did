require "rails_helper"

RSpec.describe "Api::TodoItems", type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { "Authorization" => "Bearer #{user.api_token}" } }

  before { user.regenerate_api_token }

  describe "GET /api/todo_items" do
    context "without authentication" do
      it "returns 401" do
        get api_todo_items_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid token" do
      it "returns all todos" do
        create_list(:todo_item, 3, user: user)

        get api_todo_items_path, headers: auth_headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["todo_items"].size).to eq(3)
      end

      it "filters by date" do
        create(:todo_item, user: user, due_date: Date.current)
        create(:todo_item, user: user, due_date: Date.current - 1)

        get api_todo_items_path, params: { date: Date.current.to_s }, headers: auth_headers
        expect(response.parsed_body["todo_items"].size).to eq(1)
      end

      it "filters by completed status" do
        create(:todo_item, user: user, completed: true, completed_at: Time.current)
        create(:todo_item, user: user, completed: false)

        get api_todo_items_path, params: { status: "completed" }, headers: auth_headers
        expect(response.parsed_body["todo_items"].size).to eq(1)
        expect(response.parsed_body["todo_items"].first["completed"]).to be true
      end

      it "filters by incomplete status" do
        create(:todo_item, user: user, completed: true, completed_at: Time.current)
        create(:todo_item, user: user, completed: false)

        get api_todo_items_path, params: { status: "incomplete" }, headers: auth_headers
        expect(response.parsed_body["todo_items"].size).to eq(1)
        expect(response.parsed_body["todo_items"].first["completed"]).to be false
      end

      it "returns 422 for invalid date" do
        get api_todo_items_path, params: { date: "not-a-date" }, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
