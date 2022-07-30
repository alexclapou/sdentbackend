class Api::UsersController < ApplicationController
  def index
    users = User.all.includes(:roles).map(&:serialize)
    render json: {
      users: users
    }.to_json, status: :ok
  end

  def show
    # user = current_user
    # appointments = Appointment.where(patient_id: params[:id])
    #                           .or(Appointment.where(dentist_id: params[:id]))
    #                           .or(Appointment.where(assistant_id: params[:id]))
    #                           .includes(:cabinet)
    #                           .map(&:serialize_show_to_profile)
    user = User.find_by(id: params[:id])
    if user.blank?
      render json: {
        errors: ['User does not exist']
      }.to_json, status: :bad_request and return
    end

    render json: {
      user: user&.serialize
    }.to_json, status: :ok
  end

  def get_user_fullname
    user = User.find_by(id: params[:id])
    render json: {
      name: user.name
    }.to_json, status: :ok
  end

  def get_user_email
    user = User.find_by(id: params[:id])
    puts params
    puts params
    puts params
    puts params
    puts params
    puts params
    render json: {
      name: user.email
    }.to_json, status: :ok
  end

  # only appointments for a given user
  def appointments
    appointments = Appointment.where(patient_id: params[:id])
                              .or(Appointment.where(dentist_id: params[:id]))
                              .or(Appointment.where(assistant_id: params[:id]))
                              .includes(:dentist, :patient,
                                        :assistant, :cabinet)
                              .map(&:serialize_show_to_profile)
    render json: {
      appointments: appointments
    }.to_json, status: :ok
  end

  def user_appointments
    user = User.find_by(id: params[:id])
    if user.blank?
      render json: {
        errors: ['User not logged in']
      }.to_json, status: :unauthorized
    end
    appointments = Appointment.where(patient_id: user.id)
                              .or(Appointment.where(dentist_id: user.id))
                              .or(Appointment.where(assistant_id: user.id))
                              .includes(:dentist, :patient,
                                        :assistant, :cabinet)
                              .map(&:serialize_show_to_profile)
    render json: {
      appointments: appointments
    }.to_json, status: :ok
  end

  def show_dentists
    dentists = User.with_role :dentist
    dentists = dentists.map(&:serialize_dentist)
    render json: {
      dentists: dentists
    }.to_json, status: :ok
  end

  def change_user_settings
    hash = user_settings_params.reject { |_k, v| v.blank? }
    user = User.find(1)
    user.update(hash)
  end

  def change_user_password
    user = current_user
    if user&.authenticate(params[:old_password])
      if params[:new_password] != params[:confirmed_password]
        render json: {
          errors: ['New passwords does not match']
        }.to_json, status: :bad_request and return
      end

      user.update(password: params[:new_password])
      render json: {
        success: 'Password changed'
      }.to_json, status: :ok and return
    end
    render json: {
      errors: ['Invalid password']
    }.to_json, status: :bad_request
  end

  private

  def user_settings_params
    params.require(:user_setting).permit(:first_name, :last_name, :email)
  end
end
