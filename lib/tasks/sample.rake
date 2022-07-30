namespace :sample do
  desc 'saying hi to cron'
  task test: [:environment] do
    puts "#{Time.now}     makai"
    patients_remind_appointments = User.without_role(:dentist)
                                       .without_role(:assistant)
                                       .includes(:patient_appointments)
                                       .select do |patient|
      patient.patient_appointments
             .select { |appointment| appointment.start_date > 6.months.ago }.present?
    end # need one more field for user.last_email_sent
    AppointmentEquipment.create(appointment_id: 1, equipment_id: 1, quantity: 10)
  end
end
# asd
