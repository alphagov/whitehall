class EmailSignup
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  validates_presence_of :feed

  def initialize(feed = nil, is_local_government = false)
    @feed = feed
    @feed = add_local_government(@feed) if is_local_government
  end

  attr_accessor :feed, :local_government

  def self.create(*args)
    signup = new(*args)
    signup.ensure_govdelivery_topic_exists if signup.valid?
    signup
  end

  def ensure_govdelivery_topic_exists
    Whitehall.govuk_delivery_client.topic(feed, description)
  end

  def govdelivery_url
    Whitehall.govuk_delivery_client.signup_url(feed)
  end

  def description
    Whitehall::GovUkDelivery::EmailSignupDescription.new(feed).text
  end
  alias_method :to_s, :description

  def persisted?
    false
  end

protected

  def add_local_government(feed)
    param_character = feed.include?('?') ? '&' : '?'
    "#{feed}#{param_character}relevant_to_local_government=1"
  end
end
