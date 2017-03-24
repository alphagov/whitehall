class EmailSignup
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_reader :feed
  validates_presence_of :feed

  def initialize(attributes = {})
    @attributes = attributes
    @feed = attributes[:feed]
  end

  def save
    if valid?
      ensure_govdelivery_topic_exists
      EmailAlertApiSignupWorker.perform_async(topic_id, @feed)
      true
    end
  end

  def ensure_govdelivery_topic_exists
    @ensure_govdelivery_topic_exists ||= Whitehall.govuk_delivery_client.topic(feed, description)
  end

  def topic_id
    ensure_govdelivery_topic_exists.parsed_content['partner_id']
  end

  def govdelivery_url
    Whitehall.govuk_delivery_client.signup_url(feed)
  end

  def description
    feed_url_validator.description
  end
  alias_method :to_s, :description

  def valid?
    super && feed_url_validator.valid?
  end

  def persisted?
    false
  end

protected

  def feed_url_validator
    @feed_url_validator ||= Whitehall::GovUkDelivery::FeedUrlValidator.new(feed)
  end
end
