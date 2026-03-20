class TodoItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_item, only: [ :update, :destroy ]

  def create
    @todo_item = current_user.todo_items.build(todo_item_params)

    if @todo_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to journal_path(@todo_item.due_date) }
      end
    else
      redirect_to journal_path(todo_item_params[:due_date] || Date.current), alert: @todo_item.errors.full_messages.join(", ")
    end
  end

  def update
    if params[:todo_item].key?(:completed)
      params[:todo_item][:completed] == "1" ? @todo_item.complete! : @todo_item.uncomplete!
    else
      @todo_item.update!(todo_item_params)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to journal_path(Date.current) }
    end
  end

  def destroy
    @todo_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to journal_path(Date.current) }
    end
  end

  private

  def set_todo_item
    @todo_item = current_user.todo_items.find(params[:id])
  end

  def todo_item_params
    params.require(:todo_item).permit(:title, :due_date)
  end
end
