# frozen_string_literal: true

class SearchEntriesTool < ApplicationMCPTool
  tool_name "search_entries"
  description "Search journal entries by keyword"

  property :query, type: "string", description: "Search term to find in entry bodies", required: true

  read_only


  def perform
    user = current_user
    return render(text: "Error: Not authenticated") unless user

    sanitized = ActiveRecord::Base.sanitize_sql_like(query)
    entries = user.entries
      .where("body LIKE ?", "%#{sanitized}%")
      .chronological
      .includes(:tags)

    render(text: format_results(entries))
  end

  private

  def format_results(entries)
    return "No entries found matching '#{query}'." if entries.empty?

    lines = [ "# Search results for '#{query}' (#{entries.size} found)" ]
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
