class Api::StatisticsController < ApplicationController
  def users_appointments_number
    today_users = User.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
    week_users = User.where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week).count
    month_users = User.where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month).count
    all_time_users = User.count

    today_appointments = Appointment.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
    week_appointments = Appointment.where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week).count
    month_appointments = Appointment.where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month).count
    all_time_appointments = Appointment.count
    render json: {
      stats: {
        today_users: today_users,
        week_users: week_users,
        month_users: month_users,
        all_time_users: all_time_users,
        today_appointments: today_appointments,
        week_appointments: week_appointments,
        month_appointments: month_appointments,
        all_time_appointments: all_time_appointments
      }
    }.to_json, status: :ok
  end

  def cabinet_used_equipments
    cabinet = Cabinet.find_by(id: params[:id])
    app_ids = Appointment.where(cabinet_id: cabinet.id).ids
    year_equipment_used = AppointmentEquipment.where(appointment_id: app_ids).select do |eq|
      eq.appointment.start_date.between?(Time.zone.now.beginning_of_year, Time.zone.now.end_of_year)
    end.map(&:serialize)
    week_equipments_used = AppointmentEquipment.where(appointment_id: app_ids).select do |eq|
      eq.appointment.start_date.between?(Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
    end.map(&:serialize)
    render json: {
      data: {
        year: year_equipment_used,
        week: week_equipments_used
      }
    }
  end

  def all_used_equipments
    equipments = Equipment.all.pluck(:name)
    data = {}
    data["all"] = {}
    data["all"][:week] = {}
    data["all"][:year] = {}
    data["all"][:week]["Monday"] = equipments.each_with_object(0).to_h
    data["all"][:week]["Tuesday"] = equipments.each_with_object(0).to_h
    data["all"][:week]["Wednesday"] = equipments.each_with_object(0).to_h
    data["all"][:week]["Thursday"] =  equipments.each_with_object(0).to_h
    data["all"][:week]["Friday"] = equipments.each_with_object(0).to_h
    12.times do |idx|
    data["all"][:year][Date::MONTHNAMES[idx+1]] = equipments.each_with_object(0).to_h
    end
    Cabinet.count.times do |cabinet_index|
      data["cabinet#{cabinet_index + 1}"] = {}
      data["cabinet#{cabinet_index + 1}"][:week] = {}
      data["cabinet#{cabinet_index + 1}"][:year] = {}
      app_ids = Appointment.where(cabinet_id: cabinet_index + 1).ids
      week_equipments_used = AppointmentEquipment.where(appointment_id: app_ids)
            .includes(:appointment, :equipment)
            .select{|eq| eq.appointment.start_date.between?(Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)}
      week_app_ids = week_equipments_used.pluck(:appointment_id).uniq
      week_apps = Appointment.where(id: week_app_ids)
      data["cabinet#{cabinet_index + 1}"][:week]["Monday"] = equipments.each_with_object(0).to_h
      data["cabinet#{cabinet_index + 1}"][:week]["Tuesday"] = equipments.each_with_object(0).to_h
      data["cabinet#{cabinet_index + 1}"][:week]["Wednesday"] = equipments.each_with_object(0).to_h
      data["cabinet#{cabinet_index + 1}"][:week]["Thursday"] =  equipments.each_with_object(0).to_h
      data["cabinet#{cabinet_index + 1}"][:week]["Friday"] = equipments.each_with_object(0).to_h
      week_apps.each do |appointment|
          apeq = AppointmentEquipment.where(appointment_id: appointment.id)
          apeq.each do |ap_eq|
            data["cabinet#{cabinet_index + 1}"][:week][appointment.start_date.strftime("%A")][ap_eq.equipment.name] += ap_eq.quantity
            data["all"][:week][appointment.start_date.strftime("%A")][ap_eq.equipment.name] += ap_eq.quantity
          end
      end
      12.times do |idx|
        data["cabinet#{cabinet_index + 1}"][:year][Date::MONTHNAMES[idx+1]] = equipments.each_with_object(0).to_h
      end
      year_equipments_used = AppointmentEquipment.where(appointment_id: app_ids)
                    .includes(:appointment, :equipment)
                    .select{|eq| eq.appointment.start_date.between?(Time.zone.now.beginning_of_year, Time.zone.now.end_of_year)}
      year_app_ids = year_equipments_used.pluck(:appointment_id).uniq
      year_apps = Appointment.where(id: year_app_ids)
      year_apps.each do |appointment|
        apeq = AppointmentEquipment.where(appointment_id: appointment.id)
        apeq.includes(:equipment).each do |ap_eq|
          data["cabinet#{cabinet_index + 1}"][:year][Date::MONTHNAMES[appointment.start_date.month]][ap_eq.equipment.name] += ap_eq.quantity
          data["all"][:year][Date::MONTHNAMES[appointment.start_date.month]][ap_eq.equipment.name] += ap_eq.quantity
        end
      end
    end
    render json: {
      data: data
    }.to_json, status: :ok
  end

  def equipments
    equipments = Equipment.all.map(&:serialize)
    render json: {
      equipments: equipments
    }.to_json, status: :ok
  end
end