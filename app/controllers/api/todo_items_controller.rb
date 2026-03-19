class Api::TodoItemsController < Api::BaseController
  def index
    todos = current_api_user.todo_items

    if params[:date].present?
      date = Date.parse(params[:date])
      todos = todos.for_date(date)
    end

    case params[:status]
    when "completed"
      todos = todos.completed
    when "incomplete"
      todos = todos.incomplete
    end

    todos = todos.ordered.includes(:tags)

    render json: {
      todo_items: todos.map { |todo| serialize_todo(todo) }
    }
  rescue Date::Error
    render json: { error: "Invalid date format" }, status: :unprocessable_entity
  end

  private

  def serialize_todo(todo)
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
