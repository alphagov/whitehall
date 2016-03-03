require "securerandom"
require_relative "../publishing_api_presenters"

class PublishingApiPresenters::Gone
  attr_reader :content_id

  def initialize(base_path)
    @base_path = base_path
    @content_id = SecureRandom.uuid
  end

  def content
    {
      base_path: @base_path,
      format: 'gone',
      publishing_app: 'whitehall',
      routes: [{ path: @base_path, type: 'exact' }],
    }
  end

  def update_type
    'major'
  end

  def links
    {} # Gone Item. no links
  end
end
