class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name('info@aronnax.space', 'Aronnax Offers')
  layout 'mailer'
end
