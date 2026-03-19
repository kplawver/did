class EntriesController < ApplicationController
  before_action :authenticate_user!

  def create
    @entry = current_user.entries.build(entry_params)

    if @entry.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to journal_path(@entry.posted_on) }
      end
    else
      redirect_to journal_path(entry_params[:posted_on] || Date.current), alert: @entry.errors.full_messages.join(", ")
    end
  end

  def destroy
    @entry = current_user.entries.find(params[:id])
    @entry.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to journal_path(Date.current) }
    end
  end

  private

  def entry_params
    params.require(:entry).permit(:body, :tag, :posted_on)
  end
end
