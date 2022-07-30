class Location < ApplicationRecord
  has_one :cabinet, dependent: nil
  validates :latitude, :longitude, presence: true
  validates :longitude,
            uniqueness: { scope: :latitude, message: 'The location already exists.' }
  before_create :reverse_geocode

  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if (geo = results.first)
      obj.country = geo.country if obj.country.blank?
      obj.county = geo.county if obj.county.blank?
      obj.city = geo.city || geo.city_district
      obj.suburb = geo.suburb if obj.suburb.blank?
      obj.street = geo.street if obj.street.blank?
      obj.number = geo.house_number if obj.number.blank?
      obj.postal_code = geo.postal_code if obj.postal_code.blank?
    end
  end

  def serialize
    {
      country: country,
      county: county,
      city: city,
      suburb: suburb,
      street: street,
      number: number,
      postal_code: postal_code
    }
  end
  # only convert to location once, so we can add aditional data after e.g. number, city

  def location_name
    "#{street}, #{number}, #{city}, #{country}"
  end
end
