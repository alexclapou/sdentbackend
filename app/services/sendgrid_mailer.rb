class SendgridMailer
  include SendGrid
  def self.send(to, subsitutions, template_id)
    data = {
      personalizations: [
        {
          to: [
            {
              email: to
            }
          ],
          dynamic_template_data: subsitutions
        }
      ],
      from: {
        email: 'alexandru.clapou@stud.ubbcluj.ro'
      },
      template_id: template_id,
    }
    sg = SendGrid::API.new(api_key:
      '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')
    sg.client.mail._('send').post(request_body: data)
  end
end
