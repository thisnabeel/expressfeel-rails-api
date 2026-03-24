module ApiAuthenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_api_user!
    @api_user = find_api_user
    render json: { error: "Unauthorized" }, status: :unauthorized unless @api_user
  end

  def authenticate_api_admin!
    authenticate_api_user!
    return if performed?

    render json: { error: "Forbidden" }, status: :forbidden unless @api_user.admin?
  end

  def optional_api_user
    @api_user = find_api_user
  end

  def find_api_user
    email = request.headers["X-User-Email"].to_s.strip
    token = request.headers["X-User-Token"].to_s
    return nil if email.blank? || token.blank?

    u = User.find_by(email: email)
    return nil unless u&.tokens.is_a?(Array) && u.tokens.include?(token)

    u
  end
end
