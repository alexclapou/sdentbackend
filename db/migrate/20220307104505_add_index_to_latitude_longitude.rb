class AddIndexToLatitudeLongitude < ActiveRecord::Migration[7.0]
  def change
    add_index :locations, [:latitude, :longitude], unique: true
  end
end
