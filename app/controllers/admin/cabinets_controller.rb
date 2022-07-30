class Admin::CabinetsController < ApplicationController
  def set_dentist
    user = authorize User.find_by(user_params), :admin?
    if user.nil?
      render json: {
        errors: ['The user does not exist']
      }.to_json, status: :bad_request
      nil
    end
    # we dont need to check if the user is an admin, we did it before
    cabinet = Cabinet.find_by(cabinet_params)
    if cabinet.nil?
      render json: {
        errors: ['The cabinet does not exist']
      }.to_json, status: :bad_request
      nil
    end
    # set the user role to dentist for the given cabinet
    user.add_role :dentist, cabinet
    render json: {
      success: ["#{user.first_name} #{user.last_name} is now a dentist for #{cabinet.name}"]
    }.to_json, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:id)
  end

  def cabinet_params
    params.require(:cabinet).permit(:id)
  end
end
