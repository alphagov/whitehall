# We need to set the I18n.available_locales early in the initialization process
# as it is used to generate the regex for the LocalizedRouting patch.
I18n.enforce_available_locales = false
I18n.available_locales = Whitehall.available_locales

if Rails.env.development? || Rails.env.test?
  I18n.exception_handler = lambda do |exception, locale, key, options|
    raise exception.message
  end
end
