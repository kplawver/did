# frozen_string_literal: true

class BearerTokenIdentifier < ActionMCP::GatewayIdentifier
  identifier :user
  authenticates :bearer_token

  def resolve
    token = extract_bearer_token
    raise Unauthorized, "Missing bearer token" unless token

    user = User.find_by(api_token: token)
    raise Unauthorized, "Invalid bearer token" unless user

    user
  end
end
