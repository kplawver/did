# frozen_string_literal: true

class GetJournalDayTool < ApplicationMCPTool
  tool_name "get_journal_day"
  description "Get a full day's journal including todos and entries"

  property :date, type: "string", description: "Date in YYYY-MM-DD format (defaults to today)"

  read_only


  def perform
    user = current_user
    return render(text: "Error: Not authenticated") unless user

    target_date = parse_date(date)
    todos = fetch_todos(user, target_date)
    entries = user.entries.for_date(target_date).chronological.includes(:tags)

    render(text: format_journal(target_date, todos, entries))
  end

  private

  def parse_date(date_string)
    return Date.current if date_string.blank?

    parsed = Date.parse(date_string)
    earliest = current_user.created_at.to_date
    parsed = earliest if parsed < earliest
    parsed = Date.current if parsed > Date.current
    parsed
  rescue Date::Error
    Date.current
  end

  def fetch_todos(user, target_date)
    if target_date == Date.current
      user.todo_items
        .where("(completed = ? AND due_date <= ?) OR (completed = ? AND completed_at BETWEEN ? AND ?)",
          false, Date.current,
          true, Date.current.beginning_of_day, Date.current.end_of_day)
        .ordered.includes(:tags)
    else
      user.todo_items
        .where("due_date = ? OR (completed = ? AND completed_at BETWEEN ? AND ?)",
          target_date,
          true, target_date.beginning_of_day, target_date.end_of_day)
        .ordered.includes(:tags)
    end
  end

  def format_journal(target_date, todos, entries)
    lines = []
    lines << "# Journal for #{target_date.strftime('%A, %B %-d, %Y')}"
    lines << "(#{target_date == Date.current ? 'Today' : "#{(Date.current - target_date).to_i} days ago"})"
    lines << ""

    lines << "## Todos (#{todos.count(&:completed)}/#{todos.size} completed)"
    if todos.any?
      todos.each do |todo|
        checkbox = todo.completed ? "[x]" : "[ ]"
        rolled = todo.rolled_over? ? " (rolled over from #{todo.original_due_date})" : ""
        tag_str = todo.tags.any? ? " ##{todo.tags.map(&:name).join(' #')}" : ""
        lines << "- #{checkbox} #{todo.title}#{rolled}#{tag_str}"
      end
    else
      lines << "- No todos for this day"
    end
    lines << ""

    lines << "## Entries (#{entries.size})"
    if entries.any?
      entries.each do |entry|
        tag_str = entry.tags.any? ? " [##{entry.tags.map(&:name).join(' #')}]" : ""
        lines << "### #{entry.tag.capitalize} — #{entry.created_at.strftime('%I:%M %p')}#{tag_str}"
        lines << entry.body
        lines << ""
      end
    else
      lines << "No entries for this day."
    end

    lines.join("\n")
  end
end
