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
      true
    end
  end

  def ensure_govdelivery_topic_exists
    @ensure_govdelivery_topic_exists ||=
      Services.email_alert_api.find_or_create_subscriber_list(criteria)
  end

  def criteria
    UrlToSubscriberListCriteria.new(feed).convert.merge("title" => description)
  end

  def topic_id
    ensure_govdelivery_topic_exists['subscriber_list']['gov_delivery_id']
  end

  def govdelivery_url
    ensure_govdelivery_topic_exists['subscriber_list']['subscription_url']
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
    @feed_url_validator ||= FeedUrlValidator.new(feed)
  end
end
