class EmailSignup
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(params)
    @feed = Rack::Utils.unescape(params[:feed])
    @feed = add_local_government(@feed) if params[:local_government] == '1'
  end

  attr_accessor :feed, :local_government

  def self.create(*args)
    signup = new(*args)
    signup.ensure_govdelivery_topic_exists
    signup
  end

  def ensure_govdelivery_topic_exists
    Whitehall.govuk_delivery_client.topic(feed, description)
  end

  def govdelivery_url
    Whitehall.govuk_delivery_client.signup_url(feed)
  end

  def description
    Whitehall::DocumentFilter::Description.new(@feed).text
  end
  alias_method :to_s, :description

  def persisted?
    false
  end

protected

  def add_local_government(feed)
    param_character = feed.include?('atom?') ? '&' : '?'
    "#{feed}#{param_character}relevant_to_local_government=1"
  end

end
