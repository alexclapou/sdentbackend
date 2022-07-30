class CabinetEquipment < ApplicationRecord
  belongs_to :cabinet
  belongs_to :equipment
  def serialize
    {
      id: equipment.id,
      equipment: equipment.name,
      quantity: quantity
    }
  end
end
