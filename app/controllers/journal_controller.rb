class JournalController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date

  def show
    @week_start = @date.beginning_of_week(:monday)
    @week_dates = (0..6).map { |i| @week_start + i.days }
    @days_with_content = days_with_content

    if @date == Date.current
      @todo_items = current_user.todo_items
        .where("(completed = ? AND due_date <= ?) OR (completed = ? AND completed_at BETWEEN ? AND ?)",
          false, Date.current,
          true, Date.current.beginning_of_day, Date.current.end_of_day)
        .ordered
    else
      @todo_items = current_user.todo_items
        .where("due_date = ? OR (completed = ? AND completed_at BETWEEN ? AND ?)",
          @date,
          true, @date.beginning_of_day, @date.end_of_day)
        .ordered
    end

    @entries = current_user.entries.for_date(@date).chronological
  end

  private

  def days_with_content
    past_dates = @week_dates.select { |d| d < Date.current }
    days = [ Date.current ]

    if past_dates.any?
      days += current_user.entries.where(posted_on: past_dates).distinct.pluck(:posted_on)
      days += current_user.todo_items.where(due_date: past_dates).distinct.pluck(:due_date)
      days += current_user.todo_items
        .where(completed: true, completed_at: past_dates.min.beginning_of_day..past_dates.max.end_of_day)
        .pluck(:completed_at).map(&:to_date)
    end

    days.uniq
  end

  def set_date
    @date = if params[:date].present?
              Date.parse(params[:date])
    else
              Date.current
    end

    earliest = current_user.created_at.to_date
    @date = earliest if @date < earliest
    @date = Date.current if @date > Date.current
  rescue Date::Error
    @date = Date.current
  end
end
