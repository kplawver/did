# frozen_string_literal: true

class GetTodosTool < ApplicationMCPTool
  tool_name "get_todos"
  description "Get todo items with optional filtering by date and status"

  property :date, type: "string", description: "Date in YYYY-MM-DD format (optional, returns all if omitted)"
  property :status, type: "string", description: "Filter by status: all, incomplete, or completed (default: all)"

  read_only


  def perform
    user = current_user
    return render(text: "Error: Not authenticated") unless user

    todos = user.todo_items

    if date.present?
      todos = todos.for_date(Date.parse(date))
    end

    case status
    when "completed"
      todos = todos.completed
    when "incomplete"
      todos = todos.incomplete
    end

    todos = todos.ordered.includes(:tags)

    render(text: format_todos(todos))
  rescue Date::Error
    render(text: "Error: Invalid date format. Use YYYY-MM-DD.")
  end

  private

  def format_todos(todos)
    return "No matching todos found." if todos.empty?

    lines = [ "# Todos (#{todos.size})" ]
    lines << ""
    todos.each do |todo|
      checkbox = todo.completed ? "[x]" : "[ ]"
      rolled = todo.rolled_over? ? " (rolled over from #{todo.original_due_date})" : ""
      due = " [due: #{todo.due_date}]"
      tag_str = todo.tags.any? ? " ##{todo.tags.map(&:name).join(' #')}" : ""
      lines << "- #{checkbox} #{todo.title}#{due}#{rolled}#{tag_str}"
    end
    lines.join("\n")
  end
end
