require "rails_helper"

RSpec.describe "Journal", type: :request do
  let(:user) { create(:user) }

  describe "GET /journal" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get journal_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns success" do
        get journal_path
        expect(response).to have_http_status(:success)
      end

      it "defaults to today" do
        get journal_path
        expect(response.body).to include(Date.current.strftime("%a"))
      end

      it "accepts a date parameter" do
        date = Date.current - 3.days
        get journal_path(date: date.to_s)
        expect(response).to have_http_status(:success)
      end

      it "clamps future dates to today" do
        get journal_path(date: (Date.current + 5).to_s)
        expect(response).to have_http_status(:success)
      end

      it "clamps dates before account creation to account creation date" do
        get journal_path(date: (user.created_at.to_date - 30).to_s)
        expect(response).to have_http_status(:success)
      end

      describe "today view" do
        it "shows incomplete todos with rollover" do
          old_todo = create(:todo_item, user: user, due_date: Date.current - 3)
          old_todo.update_column(:due_date, Date.current)
          today_todo = create(:todo_item, user: user, due_date: Date.current)
          completed_today = create(:todo_item, user: user, due_date: Date.current, completed: true, completed_at: Time.current)
          create(:todo_item, user: user, due_date: Date.current, completed: true, completed_at: 2.days.ago)

          get journal_path
          expect(response.body).to include(today_todo.title)
          expect(response.body).to include(completed_today.title)
        end

        it "shows today's entries" do
          entry = create(:entry, user: user, posted_on: Date.current, body: "Today's thought")
          create(:entry, user: user, posted_on: Date.current - 1, body: "Yesterday's thought")

          get journal_path
          expect(response.body).to include("Today&#39;s thought")
        end
      end

      describe "past day view" do
        it "shows todos for that date" do
          past_date = Date.current - 2
          past_todo = create(:todo_item, user: user, due_date: past_date)
          create(:todo_item, user: user, due_date: Date.current)

          get journal_path(date: past_date.to_s)
          expect(response.body).to include(past_todo.title)
        end
      end
    end
  end

  describe "authenticated root" do
    it "serves journal as root for authenticated users" do
      sign_in user
      get authenticated_root_path
      expect(response).to have_http_status(:success)
    end
  end
end
