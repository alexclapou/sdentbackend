class EmailService
  include SendGrid
  def self.call(to, subject, content)
    new.send_email(to: to, subject: subject, content: content)
  end

  def initialize
    @sendgrid = SendGrid::API.new(api_key:
      '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')
  end

  def send_email(to:, subject:, content:)
    from = Email.new(email: 'alexandru.clapou@stud.ubbcluj.ro', name: 'Sdent')
    to = Email.new(email: to)
    content = Content.new(type: 'text/plain', value: content)
    mail = Mail.new(from, subject, to, content)
    @sendgrid.client.mail._('send').post(request_body: mail.to_json)
    # response =
    # puts response.status_code
    # puts response.body
    # puts response.headers
  end
end
