# frozen_string_literal: true

class ApplicationGateway < ActionMCP::Gateway
  identified_by BearerTokenIdentifier

  def configure_session(session)
    return unless user

    session.session_data = {
      "user_id" => user.id
    }
  end
end
