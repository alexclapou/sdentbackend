class Appointment < ApplicationRecord
  enum status: {
    requested: 0,
    confirmed: 1,
    completed: 2,
    canceled: 3
  }
  has_many :appointment_equipments, dependent: :destroy
  has_many :equipments, through: :appointment_equipments # HERE

  default_scope { order(start_date: :desc, dentist_id: :asc) } # order based on something?
  belongs_to :cabinet
  belongs_to :dentist, class_name: 'User'
  belongs_to :assistant, class_name: 'User', optional: true
  belongs_to :patient, class_name: 'User'

  def serialize_show_all
    {
      id: id,
      start_date: start_date.strftime('%d %b %Y, %H:%M'),
      dentist: dentist.name,
      patient: patient.name,
      assistant: status == 'canceled' ? assistant&.name || 'None' : (assistant&.name || User.with_role(:assistant).select{|u| u.has_strict_role? :assistant, Cabinet.find(cabinet_id)}.map(&:serialize)),
      status: status
    }
  end

  def serialize_show_to_user
    {
      id: id,
      start_date: start_date.strftime('%d %b %Y, %H:%M'),
      end_date: end_date.strftime('%d %b %Y, %H:%M'),
      dentist: dentist.name,
      patient: patient.name,
      patient_id: patient.id,
      assistant: assistant&.name || 'Not confirmed',
      status: status,
      cabinet_name: cabinet.name,
      cabinet_id: cabinet_id,
      location: cabinet.location.location_name,
      description: description,
      equipments: appointment_equipments.includes(:equipment).map(&:serialize)
    }
  end

  def serialize_show_to_profile
    {
      id: id,
      date: start_date.strftime('%d %b %Y, %H:%M'),
      location: cabinet.location.location_name,
      status: status
    }
  end

  def serialize_dates
    {
      start_date: start_date.strftime('%d %b %Y, %H:%M'),
      end_date: end_date.strftime('%d %b %Y, %H:%M')
    }
  end
end
