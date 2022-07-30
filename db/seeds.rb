# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
def generate_date(cabinet_id)
  date = Time.zone.parse("#{rand(8..18)}:00") + rand(-14..14).days
  date = Time.zone.parse("#{rand(8..18)}:00") + rand(-14..14).days while date.sunday? || date.saturday? || Appointment.where(
    start_date: date, cabinet_id: cabinet_id
  ).present?
  date
end

def generate_date_completed(cabinet_id)
  date = Time.zone.parse("#{rand(8..18)}:00") + rand(-150..0).days
  date = Time.zone.parse("#{rand(8..18)}:00") + rand(-150..0).days while date.sunday? || date.saturday? || Appointment.where(
    start_date: date, cabinet_id: cabinet_id
  ).present?
  date
end


def generate_date_canceled
  date = Time.zone.parse("#{rand(8..18)}:00") + rand(-14..14).days
  date = Time.zone.parse("#{rand(8..18)}:00") + rand(-14..14).days while date.sunday? || date.saturday?
  date
end

Equipment.create(name: 'Instrument1', category: 'instrument')
Equipment.create(name: 'Instrument2', category: 'instrument')
Equipment.create(name: 'Instrument3', category: 'instrument')
Equipment.create(name: 'Instrument4', category: 'instrument')
Equipment.create(name: 'Instrument5', category: 'instrument')

Equipment.create(name: 'Material1', category: 'material')
Equipment.create(name: 'Material2', category: 'material')
Equipment.create(name: 'Material3', category: 'material')
Equipment.create(name: 'Material4', category: 'material')
Equipment.create(name: 'Material5', category: 'material')


# create cabinets and locations
Location.create(
  latitude: '47.136572948422376',
  longitude: '24.509854714609933',
  number: '18'
)

Location.create(
  latitude: '46.76970684220396',
  longitude: '23.62958473386506'
)

Location.create(
  latitude: '44.43297160848619',
  longitude: '26.07180131154563',
  county: 'Bucharest'
)

Cabinet.create(
  location_id: 1
)

Cabinet.create(
  location_id: 2
)

Cabinet.create(
  location_id: 3
)

# 1 admin user
User.create(first_name: 'Alex',
            last_name: 'Clapou', email: 'alexclapou@gmail.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true, admin: true)

# 99 patients
99.times do
  fake_first_name = Faker::Name.first_name
  fake_last_name = Faker::Name.last_name
  fake_email = "#{fake_first_name}.#{fake_last_name}@example.com"
  User.create(first_name: fake_first_name,
              last_name: fake_last_name, email: fake_email, password: 'password',
              password_confirmation: 'password', email_confirmed: true)
end

# 3 dentists
User.create(first_name: 'Mihai',
            last_name: 'Motoc', email: 'dentist1@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :dentist
User.last.add_role :dentist, Cabinet.find(1)

User.create(first_name: 'Holly',
            last_name: 'Connor', email: 'dentist2@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :dentist
User.last.add_role :dentist, Cabinet.find(2)

User.create(first_name: 'Stacy',
            last_name: 'Tyla', email: 'dentist3@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :dentist
User.last.add_role :dentist, Cabinet.find(3)

# 6 assistants
User.create(first_name: 'Roy',
            last_name: 'Londyn', email: 'assistant1@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :assistant
User.last.add_role :assistant, Cabinet.find(1)

User.create(first_name: 'Hettie',
            last_name: 'Sherri', email: 'assistant2@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :assistant
User.last.add_role :assistant, Cabinet.find(1)

User.create(first_name: 'Janie',
            last_name: 'Azalea', email: 'assistant3@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :assistant
User.last.add_role :assistant, Cabinet.find(2)

User.create(first_name: 'Jonquil',
            last_name: 'Elias', email: 'assistant4@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :assistant
User.last.add_role :assistant, Cabinet.find(2)

User.create(first_name: 'Cedar',
            last_name: 'Elicia', email: 'assistant5@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :assistant
User.last.add_role :assistant, Cabinet.find(3)

User.create(first_name: 'Kacie',
            last_name: 'Petunia', email: 'assistant6@yahoo.com', password: 'parola',
            password_confirmation: 'parola', email_confirmed: true)
User.last.add_role :assistant
User.last.add_role :assistant, Cabinet.find(3)

# 15 requested appointments
start_day = Time.zone.parse('8am').next_occurring(:monday)
6.times do
  Appointment.create(cabinet_id: 1, dentist_id: 101, patient_id: rand(2..30), start_date: start_day,
                     end_date: start_day + 1.hour, description: '')
  Appointment.create(cabinet_id: 2, dentist_id: 102, patient_id: rand(2..30), start_date: start_day,
                     end_date: start_day + 1.hour, description: '')
  Appointment.create(cabinet_id: 3, dentist_id: 103, patient_id: rand(2..30), start_date: start_day,
                     end_date: start_day + 1.hour, description: '')
  start_day += 1.day
end

# 51 confirmed appointments
18.times do
  start_hour = generate_date(1)
  Appointment.create(cabinet_id: 1, dentist_id: 101, assistant_id: [104, 105].sample, patient_id: rand(2..30),
                     start_date: start_hour, end_date: start_hour + 1.hour, status: 1, description: '')
  start_hour = generate_date(2)
  Appointment.create(cabinet_id: 2, dentist_id: 102, assistant_id: [106, 107].sample, patient_id: rand(2..30),
                     start_date: start_hour, end_date: start_hour + 1.hour, status: 1, description: '')
  start_hour = generate_date(3)
  Appointment.create(cabinet_id: 3, dentist_id: 103, assistant_id: [108, 109].sample, patient_id: rand(2..30),
                     start_date: start_hour, end_date: start_hour + 1.hour, status: 1, description: '')
end
# 99 completed appointments
250.times do
  start_hour = generate_date_completed(1)
  a = Appointment.create(cabinet_id: 1, dentist_id: 101, assistant_id: [104, 105].sample, patient_id: rand(2..30),
        start_date: start_hour, end_date: start_hour + 1.hour, status: 2, description: '')
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 1, quantity: rand(2..3))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 2, quantity: rand(2..3))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 6, quantity: rand(5..10))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 7, quantity: rand(5..10))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 8, quantity: rand(5..10))
  start_hour = generate_date_completed(2)
  a = Appointment.create(cabinet_id: 2, dentist_id: 102, assistant_id: [106, 107].sample, patient_id: rand(2..30),
  start_date: start_hour, end_date: start_hour + 1.hour, status: 2, description: '')
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 1, quantity: rand(2..3))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 3, quantity: rand(2..3))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 6, quantity: rand(5..10))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 8, quantity: rand(5..10))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 9, quantity: rand(5..10))
  start_hour = generate_date_completed(3)
  a = Appointment.create(cabinet_id: 3, dentist_id: 103, assistant_id: [108, 109].sample, patient_id: rand(2..30),
         start_date: start_hour, end_date: start_hour + 1.hour, status: 2, description: '')
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 2, quantity: rand(2..3))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 3, quantity: rand(2..3))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 8, quantity: rand(5..10))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 9, quantity: rand(5..10))
  AppointmentEquipment.create(appointment_id: a.id, equipment_id: 10, quantity: rand(5..10))
end
# 15 canceled appointments
6.times do
  start_hour = generate_date_canceled
  Appointment.create(cabinet_id: 1, dentist_id: 101, patient_id: rand(2..30), start_date: start_hour,
                     end_date: start_hour + 1.hour, status: 3, description: '')
  Appointment.create(cabinet_id: 2, dentist_id: 102, patient_id: rand(2..30), start_date: start_hour,
                     end_date: start_hour + 1.hour, status: 3, description: '')
  Appointment.create(cabinet_id: 3, dentist_id: 103, patient_id: rand(2..30), start_date: start_hour,
                     end_date: start_hour + 1.hour, status: 3, description: '')
end


1.upto(10) do |eqp_id|
  CabinetEquipment.create(equipment_id: eqp_id, cabinet_id: 1, quantity: 100)
  CabinetEquipment.create(equipment_id: eqp_id, cabinet_id: 2, quantity: 100)
  CabinetEquipment.create(equipment_id: eqp_id, cabinet_id: 3, quantity: 100)
end