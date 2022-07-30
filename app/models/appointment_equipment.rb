class AppointmentEquipment < ApplicationRecord
  belongs_to :appointment
  belongs_to :equipment

  def serialize
    {
      id: id,
      name: equipment.name,
      quantity: quantity
    }
  end
end
