class Cabinet < ApplicationRecord
  resourcify
  belongs_to :location
  has_many :cabinet_equipments, dependent: :destroy
  has_many :equipments, through: :cabinet_equipments # HERE
  before_create :set_cabinet_name
  def serialize
    {
      id: id,
      name: name,
      location: location.serialize
    }
  end

  def serialize_show_dentist
    {
      id: id,
      name: name,
      location: location.location_name
    }
  end

  private

  def set_cabinet_name
    self.name = "Sdent #{location.county}"
  end
end
