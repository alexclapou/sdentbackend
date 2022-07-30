class Api::AppointmentsController < ApplicationController
  # before_action :user_authorized

  def request_appointment
    unless Cabinet
           .where(id: params[:app_request_details][:cabinet_id])
           .present?
      render json: {
        errors: ['The cabinet does not exist']
      }.to_json, status: :bad_request and return
    end
    unless User.find_by(id: params[:app_request_details][:dentist_id])
               .has_role?(:dentist,
                          Cabinet.find(params[:app_request_details][:cabinet_id]))
      render json: {
        errors: ['The dentist is not valid']
      }.to_json, status: :bad_request and return
    end

    user = current_user
    unless params[:app_request_details][:dentist_id] != user.id # params[:app_request_details][:patient_id]
      render json: {
        errors: ['Dentist must be different from the patient']
      }.to_json, status: :bad_request and return
    end

    unless params[:app_request_details][:start_date] >= Time.zone.now
      render json: {
        errors: ['Appointment must be scheduled in the future']
      }.to_json, status: :bad_request and return
    end

    unavailable_time = Appointment
                       .where(cabinet_id: params[:app_request_details][:cabinet_id],
                              start_date: params[:app_request_details][:start_date])
                       .select { |app| app.status != 'canceled' }
                       .present?

    if unavailable_time
      render json: {
        errors: ['The date is not valid']
      }.to_json, status: :bad_request and return
    end

    end_date = Time.zone.parse(params[:app_request_details][:start_date]) + 1.hour
    appointment = Appointment.new(
      cabinet_id: params[:app_request_details][:cabinet_id],
      dentist_id: params[:app_request_details][:dentist_id],
      patient_id: user.id, # params[:app_request_details][:patient_id],
      description: params[:app_request_details][:description],
      start_date: params[:app_request_details][:start_date],
      end_date: end_date
    )

    unless appointment.save
      render json: {
        errors: appointment.errors.messages
      }.to_json, status: :bad_request
      return
    end
    render json:
    {
      success: ["Appointment #{appointment.id} created"]
    }.to_json, status: :ok
  end

  def confirm_appointment
    appointment = Appointment.find_by(id: params[:id])
    if appointment.blank?
      render json: {
        errors: ['Appointment does not exist']
      }.to_json, status: :bad_request and return
    end
    unless appointment.requested?
      render json: {
        errors: ['Appointment must have status requested']
      }.to_json, status: :bad_request and return
    end

    assistant = User.find_by(id: params[:aid])
    if assistant.blank? || !assistant.has_role?(:assistant, Cabinet.find(appointment.cabinet_id))
      render json: {
        errors: ['Assistant does not exist']
      }.to_json, status: :bad_request and return
    end

    appointment.update(assistant_id: assistant.id, status: :confirmed)
    appointments = Appointment.all.includes(:dentist, :patient, :assistant).map(&:serialize_show_all)
    render json: {
      appointments: appointments
    }.to_json, status: :ok
  end


  def show
    appointment = Appointment.find_by(id: params[:id])
    if appointment.blank?
      render json:{
        errors: ["Appointment does not exist"]
      }.to_json, status: :bad_request and return
    end
    appointment = appointment.serialize_show_to_user
    render json:{
      appointment: appointment
    }.to_json, status: :ok
  end


  def cancel_appointment
    appointment = Appointment.find_by(id: params[:id])
    if appointment.blank?
      render json: {
        errors: ['Appointment does not exist']
      }.to_json, status: :bad_request
      return
    end

    unless appointment.requested? || appointment.confirmed?
      render json: {
        errors: ['Only requested appointments can be canceled']
      }.to_json, status: :bad_request and return
    end

    user = current_user
    if user.id == appointment.dentist_id ||
       user.id == appointment.patient_id ||
       user.id == appointment.assistant_id
      appointment.update(status: :canceled)
      render json: {
        errors: ['Appointment canceled']
      }.to_json, status: :ok
      return
    end
    render json: {
      errors: ['You cannot cancel this appointments']
    }.to_json, status: :bad_request
  end

  def index
    appointments = Appointment.all.includes(:dentist, :patient, :assistant).map(&:serialize_show_all)
    render json: {
      appointments: appointments
    }.to_json, status: :ok
  end

  def unavailable_dates
    future_dates = Appointment.where(dentist_id: params[:id]).where.not(status: 'canceled')
                              .select { |app| app.start_date.future? }
                              .map(&:serialize_dates)
    render json: {
      future_dates: future_dates
    }.to_json, status: :ok
  end

  def complete_appointment
    appointment = Appointment.find_by(id: params[:id])
    unless appointment.confirmed?
      render json: {
        errors: ['Appointment must be confirmed']
      }.to_json, status: :bad_request and return
    end
    equipments = params[:equipments].pluck(:equipment_id, :quantity).map do |eq, qu|
      { appointment_id: appointment.id, equipment_id: eq, quantity: qu }
    end
    cabinet = Cabinet.find_by(id: appointment.cabinet_id)
    equipments.each do |equipment|
      cabinet_equipment = CabinetEquipment.find_by(cabinet_id: cabinet.id, equipment_id: equipment[:equipment_id])
      cabinet_equipment.update(quantity: cabinet_equipment.quantity-equipment[:quantity])
    end
    AppointmentEquipment.create(equipments)
    appointment.update(status: :completed)
    render json: {
      success: 'success'
    }.to_json, status: :ok
  end

  private

  def req_app_params
    params.require(:app_request_details).permit(:cabinet_id, :dentist_id,
                                                :patient_id, :start_date, :description)
  end
end
