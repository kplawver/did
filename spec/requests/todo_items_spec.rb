require "rails_helper"

RSpec.describe "TodoItems", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before { sign_in user }

  describe "POST /todo_items" do
    it "creates a todo item" do
      expect {
        post todo_items_path, params: { todo_item: { title: "New todo", due_date: Date.current } }, as: :turbo_stream
      }.to change(user.todo_items, :count).by(1)

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "rejects blank title" do
      post todo_items_path, params: { todo_item: { title: "", due_date: Date.current } }
      expect(response).to redirect_to(journal_path(Date.current))
    end

    it "extracts hashtags from title" do
      post todo_items_path, params: { todo_item: { title: "Fix #projectx bug", due_date: Date.current } }, as: :turbo_stream
      todo = user.todo_items.last
      expect(todo.tags.pluck(:name)).to include("projectx")
    end
  end

  describe "PATCH /todo_items/:id" do
    let(:todo_item) { create(:todo_item, user: user) }

    it "completes a todo" do
      patch todo_item_path(todo_item), params: { todo_item: { completed: "1" } }, as: :turbo_stream
      expect(todo_item.reload.completed).to be true
      expect(todo_item.completed_at).to be_present
    end

    it "uncompletes a todo" do
      todo_item.complete!
      patch todo_item_path(todo_item), params: { todo_item: { completed: "0" } }, as: :turbo_stream
      expect(todo_item.reload.completed).to be false
      expect(todo_item.completed_at).to be_nil
    end
  end

  describe "DELETE /todo_items/:id" do
    let!(:todo_item) { create(:todo_item, user: user) }

    it "deletes the todo" do
      expect {
        delete todo_item_path(todo_item), as: :turbo_stream
      }.to change(user.todo_items, :count).by(-1)
    end
  end

  describe "authorization" do
    it "cannot update another user's todo" do
      other_todo = create(:todo_item, user: other_user)
      patch todo_item_path(other_todo), params: { todo_item: { completed: "1" } }
      expect(response).to have_http_status(:not_found)
    end

    it "cannot delete another user's todo" do
      other_todo = create(:todo_item, user: other_user)
      delete todo_item_path(other_todo)
      expect(response).to have_http_status(:not_found)
    end
  end
end
