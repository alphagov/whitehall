require 'securerandom'

module PublishingApiPresenters
  class ItemRedirect
    attr_reader :content_id

    def initialize(item, _options = {})
      @redirects = item.redirects
      @base_path = item.base_path
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
