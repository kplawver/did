# frozen_string_literal: true

class ApplicationMCPTool < ActionMCP::Tool
  abstract!

  private

  def current_user
    @current_user ||= User.find_by(id: session_data&.dig("user_id"))
  end
end
