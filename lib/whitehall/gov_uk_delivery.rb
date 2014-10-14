module Whitehall
  module GovUkDelivery
    autoload :EmailFormatter, 'whitehall/gov_uk_delivery/email_formatter'
    autoload :FeedUrlValidator, 'whitehall/gov_uk_delivery/feed_url_validator'
    autoload :Notifier, 'whitehall/gov_uk_delivery/notifier'
    autoload :SubscriptionUrlGenerator, 'whitehall/gov_uk_delivery/subscription_url_generator'
    autoload :Worker, 'whitehall/gov_uk_delivery/worker'
  end
end
