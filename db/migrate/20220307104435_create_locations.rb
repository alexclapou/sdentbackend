class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.float :latitude
      t.float :longitude
      t.string :street
      t.string :suburb
      t.string :city
      t.string :county
      t.string :postal_code
      t.string :country
      t.string :number

      t.timestamps
    end
  end
end
