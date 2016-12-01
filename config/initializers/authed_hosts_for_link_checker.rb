# This ENV var is only populated for the integration deployment environment.
if ENV.has_key?("BASIC_AUTH_CREDENTIALS")
  LinksChecker.authed_domains = { "www.#{ENV['GOVUK_APP_DOMAIN']}" => ENV.fetch["BASIC_AUTH_CREDENTIALS"] }
end
