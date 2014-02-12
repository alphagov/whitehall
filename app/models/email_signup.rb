class EmailSignup
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_reader :feed
  validates_presence_of :feed

  def initialize(attributes={})
    @attributes = attributes
    @feed = local_government ? add_local_government(attributes[:feed]) : attributes[:feed]
  end

  def save
    if valid?
      ensure_govdelivery_topic_exists
      true
    end
  end

  def local_government
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(@attributes[:local_government])
  end

  def ensure_govdelivery_topic_exists
    Whitehall.govuk_delivery_client.topic(feed, description)
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

  def add_local_government(feed)
    param_character = feed.include?('?') ? '&' : '?'
    "#{feed}#{param_character}relevant_to_local_government=1"
  end
end
