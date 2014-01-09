require 'uri'
require 'cgi'

class EmailSignup
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations

  def initialize(params)
    @feed = Rack::Utils.unescape(params[:feed])
    @feed = add_local_government(@feed) if params[:local_government] == '1'
  end

  attr_accessor :feed, :local_government

  validate :valid_feed?

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

  def valid_feed?
    if parsed_feed.scheme != 'https'
      errors.add('feed', "needs to start with https")
    end

    if parsed_feed.host != Whitehall.public_host
      errors.add('feed', "must use #{Whitehall.public_host} domain")
    end

    if parsed_feed.path !~ %r{^/government/}
      errors.add('feed', "must be a /government URL")
    end

    if invalid_params?
      errors.add('feed', "contains invalid filter options")
    end
  end

  def invalid_params?
    params.any? do |key, values|
      values.any? do |value|
        !Whitehall::DocumentFilter::Options.valid_filter_key_and_value?(key, value) || !correct_filter_key_for_document_type?(key)
      end
    end
  end

  def correct_filter_key_for_document_type?(filter_key)
    case filter_key
    when 'publication_filter_option'
      document_type && document_type.include?('publications')
    when 'announcement_type_option'
      document_type && document_type.include?('announcements')
    else
      true
    end
  end

  def params
    if query_string = parsed_feed.query
      default_params.merge(CGI.parse(query_string))
    else
      {}
    end
  end

  def default_params
    if document_type
      {'document_type' => document_type}
    else
      {}
    end
  end

  def document_type
    if parsed_feed.path =~ %r{/government/(.+)\..*}
      [$1] if ['announcements', 'publications', 'policies'].include?($1)
    end
  end

  def parsed_feed
    @parsed_feed ||= URI.parse(@feed)
  end

end
