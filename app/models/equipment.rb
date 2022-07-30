class Equipment < ApplicationRecord
  enum category: {
    material: 0,
    instrument: 1,
  }

  def serialize
    {
      id: id,
      name: name
    }
  end
end
