class Api::EntriesController < Api::BaseController
  def index
    entries = current_api_user.entries

    if params[:date].present?
      entries = entries.for_date(Date.parse(params[:date]))
    elsif params[:from].present? || params[:to].present?
      from = params[:from].present? ? Date.parse(params[:from]) : current_api_user.created_at.to_date
      to = params[:to].present? ? Date.parse(params[:to]) : Date.current
      entries = entries.where(posted_on: from..to)
    end

    entries = entries.by_tag(params[:tag]) if params[:tag].present?
    entries = entries.chronological.includes(:tags)

    render json: {
      entries: entries.map { |entry| serialize_entry(entry) }
    }
  rescue Date::Error
    render json: { error: "Invalid date format" }, status: :unprocessable_entity
  end

  def search
    query = params[:q].to_s.strip
    if query.blank?
      render json: { error: "Query parameter 'q' is required" }, status: :unprocessable_entity
      return
    end

    entries = current_api_user.entries
      .where("body LIKE ?", "%#{sanitize_sql_like(query)}%")
      .chronological
      .includes(:tags)

    render json: {
      query: query,
      entries: entries.map { |entry| serialize_entry(entry) }
    }
  end

  private

  def serialize_entry(entry)
    {
      id: entry.id,
      body: entry.body,
      tag: entry.tag,
      posted_on: entry.posted_on.to_s,
      created_at: entry.created_at.iso8601,
      tags: entry.tags.map(&:name)
    }
  end

  def sanitize_sql_like(string)
    ActiveRecord::Base.sanitize_sql_like(string)
  end
end
