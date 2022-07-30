# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_05_06_142509) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointment_equipments", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "equipment_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_equipments_on_appointment_id"
    t.index ["equipment_id"], name: "index_appointment_equipments_on_equipment_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.bigint "cabinet_id", null: false
    t.bigint "dentist_id", null: false
    t.bigint "assistant_id"
    t.bigint "patient_id", null: false
    t.integer "status", default: 0
    t.index ["assistant_id"], name: "index_appointments_on_assistant_id"
    t.index ["cabinet_id"], name: "index_appointments_on_cabinet_id"
    t.index ["dentist_id"], name: "index_appointments_on_dentist_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
  end

  create_table "cabinet_equipments", force: :cascade do |t|
    t.bigint "cabinet_id", null: false
    t.bigint "equipment_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cabinet_id"], name: "index_cabinet_equipments_on_cabinet_id"
    t.index ["equipment_id"], name: "index_cabinet_equipments_on_equipment_id"
  end

  create_table "cabinets", force: :cascade do |t|
    t.string "name"
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_cabinets_on_location_id"
  end

  create_table "equipment", force: :cascade do |t|
    t.string "name"
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.string "street"
    t.string "suburb"
    t.string "city"
    t.string "county"
    t.string "postal_code"
    t.string "country"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_locations_on_latitude_and_longitude", unique: true
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.string "token"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "email_confirmed", default: false
    t.string "confirm_token"
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "appointment_equipments", "appointments"
  add_foreign_key "appointment_equipments", "equipment"
  add_foreign_key "appointments", "cabinets"
  add_foreign_key "appointments", "users", column: "assistant_id"
  add_foreign_key "appointments", "users", column: "dentist_id"
  add_foreign_key "appointments", "users", column: "patient_id"
  add_foreign_key "cabinet_equipments", "cabinets"
  add_foreign_key "cabinet_equipments", "equipment"
  add_foreign_key "cabinets", "locations"
  add_foreign_key "refresh_tokens", "users"
end
