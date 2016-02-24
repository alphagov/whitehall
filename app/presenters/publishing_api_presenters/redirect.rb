require 'securerandom'
require_relative "../publishing_api_presenters"

module PublishingApiPresenters
  class Redirect
    attr_reader :content_id

    def initialize(base_path, redirects)
      @redirects = redirects
      @base_path = base_path
      @content_id = SecureRandom.uuid
    end

    def content
      {
        base_path: @base_path,
        format: 'redirect',
        publishing_app: 'whitehall',
        redirects: @redirects
      }
    end

    def links
      {}
    end

    def update_type
      'major'
    end
  end
end
