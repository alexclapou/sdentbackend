class User < ApplicationRecord
  has_many :refresh_token, dependent: :destroy
  has_many :dentist_appointments, class_name: 'Appointment',
                                  foreign_key: 'dentist_id', dependent: :destroy
  has_many :assistant_appointments, class_name: 'Appointment',
                                    foreign_key: 'assistant_id', dependent: :destroy
  has_many :patient_appointments, class_name: 'Appointment',
                                  foreign_key: 'patient_id', dependent: :destroy

  rolify
  has_secure_password
  after_create :assign_default_role
  after_create :send_confirmation_email, unless: -> { email_confirmed? } # ?don't send email if seed db
  before_save { self.email = email.downcase }

  validates :first_name, :last_name, :email, presence: true
  validates :first_name,
            length: { minimum: 2, maximum: 30, message: 'First name length is not valid' },
            unless: lambda {
                      first_name.blank?
                    }
  validates :last_name,
            length: { minimum: 2, maximum: 30, message: 'Last name length is not valid' },
            unless: -> { last_name.blank? }
  validates :email, uniqueness: { case_sensitive: false, message: 'The email already exists' },
                    format: { with: URI::MailTo::EMAIL_REGEXP,
                              message: 'The email is not valid' },
                    unless: -> { email.blank? }

  validates :password, confirmation: { message: 'Passwords does not match' },
                       length: { minimum: 2, maximum: 30, message: 'Password length is not valid' },
                       unless: -> { password.blank? }

  def confirmed_account?
    email_confirmed
  end

  def generate_refresh_token(token_to_delete = nil)
    RefreshToken.find_by(token: token_to_delete).destroy if token_to_delete.present? && RefreshToken.find_by(token: token_to_delete).present?
    payload = {
      id: id,
    }
    new_refresh_token = JsonWebToken.encode(payload, 20.years.from_now)
    RefreshToken.create(token: new_refresh_token, user_id: id)
    new_refresh_token
  end

  def payload_jwt
    {
      id: id,
      email: email,
      first_name: first_name,
      last_name: last_name,
      role: admin ? 'admin' : role
    }
  end

  def serialize_dentist
    {
      id: id,
      name: name,
      email: email,
      cabinet: Cabinet.with_role(:dentist, self).first.serialize_show_dentist
    }
  end

  def name
    "#{first_name} #{last_name}"
  end

  def role
    roles.map(&:name)[roles.length - 1]
  end

  def serialize
    {
      id: id,
      name: name,
      email: email,
      joined_at: created_at.strftime('%d %b %Y'),
      role: role
    }
  end


  private

  def assign_default_role
    add_role(:patient) if roles.blank?
  end

  def send_confirmation_email
    # EmailService.call email, 'Sdent', 'asdasdasdasdas'
    payload = {
      id: id
    }
    confirmation_token = JsonWebToken.encode(payload, 1.hour.from_now)
    SendgridMailer.send email, { first_name: first_name,
                                 confirmation_link: 'http://localhost:3000/auth/confirmation/'\
                                  + confirmation_token },
                        'd-11ce8401b59140a6b4d7f7883fa50212' # using first_name variable and template-id
  end

  def send_reset_password_email; end
end
