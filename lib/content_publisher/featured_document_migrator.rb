module ContentPublisher
  class FeaturedDocumentMigrator
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def call
      edition = document.live_edition.presence || document.latest_edition

      public_url = Whitehall.url_maker.public_document_url(edition)
      public_updated_at = (edition.public_timestamp || edition.updated_at)

      Feature.includes(:feature_list).where(document_id: document.id).each do |feature|
        offsite_link = OffsiteLink.create!(
          title: edition.title,
          summary: edition.summary,
          link_type: "content_publisher_#{link_type(edition)}",
          url: public_url,
          date: public_updated_at,
          parent_type: feature.feature_list.featurable_type,
          parent_id: feature.feature_list.featurable_id,
        )
        feature.update!(document_id: nil, offsite_link_id: offsite_link.id)
      end
    end

    def link_type(edition)
      edition.news_article_type.key
    end
  end
end
