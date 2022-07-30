class JsonWebToken
  SECRET_KEY = Rails.application.secrets.jwt_secret

  # def self.encode(payload, exp = Time.zone.now)
  def self.encode(payload, exp = 1.hour.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY)[0]
  rescue JWT::ExpiredSignature
    nil
  end
end
