class CreateAppointmentEquipments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointment_equipments do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
