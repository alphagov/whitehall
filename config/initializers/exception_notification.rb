unless Rails.env.development? or Rails.env.test?
  Rails.application.config.middleware.use ExceptionNotifier,
    email_prefix: "[#{Rails.application.class.name.split('::').first} (#{Plek.current.environment})] ",
    sender_address: %{"Winston Smith-Churchill" <winston@alphagov.co.uk>},
    exception_recipients: %w{govuk-exceptions@digital.cabinet-office.gov.uk}
end
