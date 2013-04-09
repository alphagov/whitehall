class EmailSignup::GovUkDeliveryRedirectUrlExtractor
  def initialize(alert)
    @alert = alert
  end

  def feed_url_for_topic
    EmailSignup::FeedUrlExtractor.new(@alert).feed_url
  end

  def title_for_topic
    EmailSignup::TitleExtractor.new(@alert).title
  end

  def gov_uk_delivery_topic
    Whitehall.govuk_delivery_client.topic(feed_url_for_topic, title_for_topic)
  end

  def redirect_url
    Whitehall.govuk_delivery_client.new_signup_url(gov_uk_delivery_topic)
  end
end
