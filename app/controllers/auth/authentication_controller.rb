class Auth::AuthenticationController < ApplicationController
  before_action :redirect_if_logged_in, only: %i[login register]

  def login
    user = User.find_by(email: params[:user][:email].downcase)
    if user.blank?
      render json: {
        errors: [
          'Invalid email/password combination'
        ]
      }, status: :bad_request
      return
    end
    unless user.email_confirmed?
      render json:
        {
          errors: ['This email is not confirmed.']
        }.to_json, status: :bad_request
      return
    end
    if user&.authenticate(params[:user][:password])
      payload = user.payload_jwt
      access_token = JsonWebToken.encode(payload)
      refresh_token = user.generate_refresh_token
      assign_token refresh_token
      render json: {
        jwt: access_token
      }.to_json, status: :ok
      return
    end
    render json: {
      errors: [
        'Invalid email/password combination'
      ]
    }, status: :bad_request
  end

  # done
  def register
    user_exists = User.find_by(email: params[:user][:email])
    if user_exists
      render json: {
        errors: [
          'Email already exists'
        ]
      }, status: :bad_request
      return
    end
    user = User.new(user_params)
    unless user.save
      render json: {
        errors: user.errors.messages
      }.to_json, status: :bad_request
      return
    end
    render json:
    {
      success: ['Confirmation email sent.']
    }.to_json, status: :ok
  end

  # done
  def logout
    clear_tokens
    render json: {
      success: 'User logged out'
    }.to_json, status: :ok
  end

  def refresh
    access_token = request.headers['Authorization'].split.last
    token = JsonWebToken.decode(access_token)

    if token.blank?
      user = current_user
      refresh_token = cookies[:r_token]
      r_token = user.generate_refresh_token(refresh_token)
      payload = user.payload_jwt
      a_token = JsonWebToken.encode(payload)
      render json: {
        jwt: a_token
      }.to_json, status: :ok
      assign_token r_token
    else
      render json: {
        errors: ['Token still valid']
      }.to_json, status: :bad_request
    end
  end

  def remove_refresh_token
    clear_tokens
  end

  private

  def redirect_if_not_logged_in
    return nil if signed_in?

    render json: {
      errors: ['User is not logged in']
    }.to_json, status: :bad_request
  end

  def redirect_if_logged_in
    return nil unless signed_in?

    render json: {
      errors: ['User already logged in']
    }.to_json, status: :bad_request
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password,
                                 :password_confirmation)
  end
end
