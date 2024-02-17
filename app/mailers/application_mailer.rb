class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name('info@aronnax.space', 'Aronnax Events')
  layout 'mailer'
end
