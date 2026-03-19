# frozen_string_literal: true

class GetEntriesTool < ApplicationMCPTool
  tool_name "get_entries"
  description "Get journal entries with optional filtering by date range and tag"

  property :date, type: "string", description: "Specific date in YYYY-MM-DD format (optional)"
  property :from, type: "string", description: "Start date for range in YYYY-MM-DD format (optional)"
  property :to, type: "string", description: "End date for range in YYYY-MM-DD format (optional)"
  property :tag, type: "string", description: "Filter by entry type: did, thought, idea, win, or emotion (optional)"

  read_only


  def perform
    user = current_user
    return render(text: "Error: Not authenticated") unless user

    entries = user.entries

    if date.present?
      entries = entries.for_date(Date.parse(date))
    elsif from.present? || to.present?
      from_date = from.present? ? Date.parse(from) : user.created_at.to_date
      to_date = to.present? ? Date.parse(to) : Date.current
      entries = entries.where(posted_on: from_date..to_date)
    end

    entries = entries.by_tag(tag) if tag.present?
    entries = entries.chronological.includes(:tags)

    render(text: format_entries(entries))
  rescue Date::Error
    render(text: "Error: Invalid date format. Use YYYY-MM-DD.")
  end

  private

  def format_entries(entries)
    return "No matching entries found." if entries.empty?

    lines = [ "# Entries (#{entries.size})" ]
    lines << ""
    entries.each do |entry|
      tag_str = entry.tags.any? ? " [##{entry.tags.map(&:name).join(' #')}]" : ""
      lines << "## #{entry.tag.capitalize} — #{entry.posted_on} #{entry.created_at.strftime('%I:%M %p')}#{tag_str}"
      lines << entry.body
      lines << ""
    end
    lines.join("\n")
  end
end
