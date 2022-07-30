class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    token = cookies[:r_token]
    if token.blank?
      token = request.headers['Authorization']
      return nil if token.blank?

      token = token.split.last
      token_decoded ||= JsonWebToken.decode(token)
      return nil if token_decoded.blank?

      c_user = User.find_by(id: token_decoded['id'])
      return c_user
    end

    token = token.split.last
    token_decoded ||= JsonWebToken.decode(token)
    if token_decoded.blank?
      render json: {
        errors: ['Token expired']
      }.to_json, status: :unauthorized
      return nil
    end

    User.find_by(id: token_decoded['id'])
  end

  def user_authorized
    token = request.headers['Authorization']
    if token.blank?
      render json: {
        errors: ['User is not logged in']
      }.to_json, status: :unauthorized
      return
    end

    token = token.split.last
    token_decoded ||= JsonWebToken.decode(token)
    if token_decoded.blank?
      render json: {
        errors: ['Token expired']
      }.to_json, status: :unauthorized
      return
    end
    nil
  end

  def signed_in?
    !current_user.nil?
  end

  protected

  def assign_token(refresh)
    cookies.permanent[:r_token] = { value: refresh }
  end

  def clear_tokens
    refresh_token = cookies[:r_token]
    cookies.delete :r_token
    RefreshToken.find_by(token: refresh_token).destroy if refresh_token.present?
  end

  private

  def user_not_authorized
    render json:
    {
      errors: ['You are not authorized to perform this action.']
    }
  end
end
