class Api::CabinetsController < ApplicationController
  def index
    cabinets = Cabinet.all.includes(:location)
    c = cabinets.map(&:serialize)
    render json: {
      cabinets: c
    }.to_json, status: :ok
  end

  def show
    cabinet = Cabinet.find_by(id: params[:id])
    if cabinet.nil?
      render json: {
        errors: ['The cabinet does not exist']
      }.to_json, status: :bad_request
      return
    end
    c = cabinet.serialize
    render json: {
      cabinet: c
    }.to_json, status: :ok
  end

  def update_equipment_quantity
    cabinet = Cabinet.find_by(id: params[:id])
    if cabinet.blank?
      render json: {
        errors: ['Cabinet does not exist']
      }.to_json, status: :bad_request and return
    end

    equipment = Equipment.find_by(id: params[:mid])
    if equipment.blank?
      render json: {
        errors: ['Equipment does not exist']
      }.to_json, status: :bad_request and return
    end

    if params[:quantity].to_i < 1 || params[:quantity].count('a-zA-Z').positive?
      render json: {
        errors: ['Invalid quantity']
      }.to_json, status: :bad_request and return
    end

    cabinet_equipment = CabinetEquipment.where(cabinet_id: cabinet.id,
                                               equipment_id: equipment.id).first
    cabinet_equipment_quantity = cabinet_equipment.quantity
    cabinet_equipment_quantity += params[:quantity].to_i
    cabinet_equipment.update(quantity: cabinet_equipment_quantity)
    render json: {
      success: "Quantity updated. Now #{cabinet_equipment_quantity}"
    }.to_json, status: :ok
  end

  def cabinet_equipments
    cabinet = Cabinet.find_by(id: params[:id])
    if cabinet.blank?
      render json: {
        errors: ['Cabinet does not exist']
      }.to_json, status: :bad_request and return
    end
    equipments = CabinetEquipment.where(cabinet_id: cabinet.id).includes(:equipment).map(&:serialize)
    render json:{
      equipments: equipments
    }.to_json, status: :ok
  end
end
