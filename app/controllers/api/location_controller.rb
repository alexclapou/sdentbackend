class Api::LocationController < ApplicationController
  def location_by_city
    location = Location.find(params[:id]).serialize
    render json:
      location.to_json
  end
end
