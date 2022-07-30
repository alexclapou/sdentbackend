class Auth::ConfirmationsController < ApplicationController
  def confirm_email
    token = params[:token]
    decoded_token = JsonWebToken.decode(token)
    user_id = decoded_token['id']
    user = User.find(user_id)
    if user
      if user.email_confirmed?
        render json: {
          errors: [
            'Email already confirmed'
          ]
        }.to_json
        return
      end
      user.update(email_confirmed: true)
      redirect_to 'http://localhost:3001/login', allow_other_host: true
      return
    end
    render json: {
      errors: [
        "Couldn't find anything"
      ]
    }.to_json
  end
end
