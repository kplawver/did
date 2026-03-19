require "rails_helper"

RSpec.describe TodoItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:taggings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:due_date) }
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".incomplete" do
      it "returns only incomplete todos" do
        incomplete = create(:todo_item, user: user, completed: false)
        create(:todo_item, user: user, completed: true, completed_at: Time.current)
        expect(described_class.incomplete).to eq([ incomplete ])
      end
    end

    describe ".for_date" do
      it "returns todos for a specific date" do
        today = create(:todo_item, user: user, due_date: Date.current)
        create(:todo_item, user: user, due_date: Date.current - 1)
        expect(described_class.for_date(Date.current)).to eq([ today ])
      end
    end

    describe ".due_on_or_before" do
      it "returns todos due on or before a date" do
        past = create(:todo_item, user: user, due_date: Date.current - 2)
        today = create(:todo_item, user: user, due_date: Date.current)
        create(:todo_item, user: user, due_date: Date.current + 1)
        expect(described_class.due_on_or_before(Date.current)).to match_array([ past, today ])
      end
    end

    describe ".completed_on" do
      it "returns todos completed on a specific date" do
        completed_today = create(:todo_item, user: user, completed: true, completed_at: Time.current)
        create(:todo_item, user: user, completed: true, completed_at: 1.day.ago)
        expect(described_class.completed_on(Date.current)).to eq([ completed_today ])
      end
    end

    describe ".ordered" do
      it "orders by position then created_at" do
        second = create(:todo_item, user: user)
        first = create(:todo_item, user: user)
        first.update_column(:position, 1)
        second.update_column(:position, 2)
        expect(described_class.ordered).to eq([ first, second ])
      end
    end
  end

  describe "callbacks" do
    it "sets original_due_date from due_date on create" do
      todo = create(:todo_item, due_date: Date.new(2026, 3, 15))
      expect(todo.original_due_date).to eq(Date.new(2026, 3, 15))
    end

    it "auto-increments position" do
      user = create(:user)
      first = create(:todo_item, user: user)
      second = create(:todo_item, user: user)
      expect(first.position).to eq(1)
      expect(second.position).to eq(2)
    end
  end

  describe "#complete!" do
    it "marks the todo as completed with a timestamp" do
      todo = create(:todo_item)
      todo.complete!
      expect(todo.completed).to be true
      expect(todo.completed_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "#uncomplete!" do
    it "marks the todo as incomplete and clears timestamp" do
      todo = create(:todo_item, completed: true, completed_at: Time.current)
      todo.uncomplete!
      expect(todo.completed).to be false
      expect(todo.completed_at).to be_nil
    end
  end

  describe "#rolled_over?" do
    it "returns true when due_date differs from original_due_date" do
      todo = create(:todo_item, due_date: Date.current)
      todo.update_column(:due_date, Date.current + 1)
      todo.reload
      expect(todo.rolled_over?).to be true
    end

    it "returns false when dates match" do
      todo = create(:todo_item)
      expect(todo.rolled_over?).to be false
    end
  end

  describe "hashtag extraction" do
    it "extracts hashtags from title and creates tags" do
      todo = create(:todo_item, title: "Fix bug in #projectX and #backend")
      expect(todo.tags.pluck(:name)).to match_array(%w[projectx backend])
    end

    it "does not create duplicate tags" do
      create(:tag, name: "projectx")
      todo = create(:todo_item, title: "Work on #projectX")
      expect(Tag.where(name: "projectx").count).to eq(1)
      expect(todo.tags.pluck(:name)).to eq(%w[projectx])
    end
  end
end
