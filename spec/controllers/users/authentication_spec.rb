require 'rails_helper'

RSpec.describe 'Users::Authentications', type: :request do
  before(:all) do
    @registered_user = User.create(first_name: 'Alex',
                                   last_name: 'Clapou',
                                   email: 'alexclapou@gmail.com',
                                   password: 'parola',
                                   password_confirmation: 'parola',
                                   email_confirmed: true)
    @not_confirmed_email = User.create(first_name: 'invalid',
                                       last_name: 'invalid',
                                       email: 'unconfirmed@yahoo.com',
                                       password: 'parola',
                                       password_confirmation: 'parola')
  end

  it 'should get error for invalid email/password' do
    post users_login_url, params: {
      user: {
        email: 'invalid@email.com',
        password: 'invalidpassword'
      }
    }
    expect(response).to have_http_status(:bad_request)
    response_hash = JSON.parse(response.body)
    error = response_hash['errors']
    expect(error).to eq ['Invalid email/password combination']
  end

  it 'should get error email not confirmed' do
    post users_login_url, params: {
      user: {
        email: @not_confirmed_email.email,
        password: @not_confirmed_email.password
      }
    }
    expect(response).to have_http_status(:bad_request)
    response_hash = JSON.parse(response.body)
    error = response_hash['errors']
    expect(error).to eq ['This email is not confirmed.']
  end

  it 'should be succesful' do
    post users_login_url, params: {
      user: {
        email: @registered_user.email,
        password: @registered_user.password
      }
    }
    expect(response).to have_http_status(:ok)
    response_hash = JSON.parse(response.body)
    jwt = response_hash['jwt']
    expect(jwt).not_to be_empty
  end
end
