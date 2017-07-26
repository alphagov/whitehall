require "securerandom"

# A temporary content format used as a splash page for scheduled documents.
#
# When a piece of content is scheduled for publication, a "coming_soon" content
# item is pushed to the Publishing API, along with a `PublishIntent` for the
# scheduled publication time. This is to get around the fact that the current
# caching infrastructure will cache a 404 for 30 minutes without honouring any
# upstream caching headers it receives. By publishing a temporary "coming soon"
# page, we can get around this issue and ensure that the cache headers that are
# set according to the scheduled publication time will be honored, thus
# preventing a 404 page from being cached for up to 30 minutes from the point
# the document was published.
#
# Note this format becomes redundant once the caching infrastructure is able to
# honour caching headers on upstream 404 responses.

module PublishingApi
  class ComingSoonPresenter
    attr_reader :content_id
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
      @content_id = SecureRandom.uuid
    end

    def content
      content = BaseItemPresenter.new(
        item,
        title: 'Coming soon',
        need_ids: [],
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: 'Coming soon',
        details: details,
        document_type: 'coming_soon',
        public_updated_at: item.updated_at,
        rendering_app: item.rendering_app,
        schema_name: 'coming_soon',
      )
      content.merge!(PayloadBuilder::PublicDocumentPath.for(item))
    end

    def links
      {}
    end

  private

    def details
      { publish_time: item.scheduled_publication.as_json }
    end
  end
end
