class CreateCabinets < ActiveRecord::Migration[7.0]
  def change
    create_table :cabinets do |t|
      t.string :name
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
