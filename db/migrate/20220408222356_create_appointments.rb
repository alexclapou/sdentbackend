class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.text :description
      t.timestamps
      t.datetime :start_date
      t.datetime :end_date
      t.references :cabinet, null: false, foreign_key: true
      t.references :dentist, null: false, foreign_key: { to_table: :users }
      t.references :assistant, null: true, foreign_key: { to_table: :users }
      t.references :patient, null: false, foreign_key: { to_table: :users }
    end
  end
end
