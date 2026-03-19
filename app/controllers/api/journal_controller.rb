class Api::JournalController < Api::BaseController
  def show
    date = parse_date(params[:date])
    todo_items = fetch_todos(date)
    entries = current_api_user.entries.for_date(date).chronological

    render json: {
      date: date.to_s,
      is_today: date == Date.current,
      todo_items: serialize_todos(todo_items),
      entries: serialize_entries(entries),
      summary: build_summary(todo_items, entries)
    }
  end

  private

  def parse_date(date_string)
    date = Date.parse(date_string)
    earliest = current_api_user.created_at.to_date
    date = earliest if date < earliest
    date = Date.current if date > Date.current
    date
  rescue Date::Error
    Date.current
  end

  def fetch_todos(date)
    if date == Date.current
      current_api_user.todo_items
        .where("(completed = ? AND due_date <= ?) OR (completed = ? AND completed_at BETWEEN ? AND ?)",
          false, Date.current,
          true, Date.current.beginning_of_day, Date.current.end_of_day)
        .ordered
    else
      current_api_user.todo_items
        .where("due_date = ? OR (completed = ? AND completed_at BETWEEN ? AND ?)",
          date,
          true, date.beginning_of_day, date.end_of_day)
        .ordered
    end
  end

  def serialize_todos(todos)
    todos.includes(:tags).map do |todo|
      {
        id: todo.id,
        title: todo.title,
        completed: todo.completed,
        completed_at: todo.completed_at&.iso8601,
        due_date: todo.due_date.to_s,
        original_due_date: todo.original_due_date.to_s,
        rolled_over: todo.rolled_over?,
        tags: todo.tags.map(&:name)
      }
    end
  end

  def serialize_entries(entries)
    entries.includes(:tags).map do |entry|
      {
        id: entry.id,
        body: entry.body,
        tag: entry.tag,
        posted_on: entry.posted_on.to_s,
        created_at: entry.created_at.iso8601,
        tags: entry.tags.map(&:name)
      }
    end
  end

  def build_summary(todos, entries)
    completed = todos.count(&:completed)
    incomplete = todos.count { |t| !t.completed }
    rolled_over = todos.count(&:rolled_over?)

    entry_tags = entries.group_by(&:tag).transform_values(&:count)

    {
      total_todos: completed + incomplete,
      completed_todos: completed,
      incomplete_todos: incomplete,
      rolled_over_todos: rolled_over,
      entry_count: entries.size,
      entry_tags: entry_tags
    }
  end
end
