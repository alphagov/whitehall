module PublishingApi
  class NewsArticlePresenter
    extend Forwardable
    include UpdateTypeHelper

    SCHEMA_NAME = "news_article".freeze

    attr_reader :update_type

    def initialize(news_article, update_type: nil)
      self.news_article = news_article
      self.update_type = update_type || default_update_type(news_article)
    end

    def_delegator :news_article, :content_id

    def content
      BaseItemPresenter
        .new(news_article, update_type: update_type)
        .base_attributes
        .merge(PayloadBuilder::AccessLimitation.for(news_article))
        .merge(PayloadBuilder::FirstPublishedAt.for(news_article))
        .merge(PayloadBuilder::PublicDocumentPath.for(news_article))
        .merge(
          description: news_article.summary,
          details: details,
          document_type: document_type,
          public_updated_at: public_updated_at,
          rendering_app: news_article.rendering_app,
          schema_name: SCHEMA_NAME,
        )
    end

    def links
      link_keys = %i(
        organisations
        parent
        policy_areas
        related_policies
        topics
        world_locations
        worldwide_organisations
        government
      )

      LinksPresenter
        .new(news_article)
        .extract(link_keys)
        .merge(PayloadBuilder::People.for(news_article, :ministers))
        .merge(PayloadBuilder::TopicalEvents.for(news_article))
        .merge(PayloadBuilder::Roles.for(news_article))
        .merge(PayloadBuilder::People.for(news_article, :people))
    end

    def document_type
      display_type_key
    end

  private

    attr_accessor :news_article
    attr_writer :update_type

    def_delegator :news_article, :display_type_key

    def base_details
      {
        body: body,
        emphasised_organisations: emphasised_organisations,
      }
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(news_article)
    end

    def details
      base_details
        .merge(ChangeHistory.for(news_article))
        .merge(Image.for(news_article))
        .merge(PayloadBuilder::FirstPublicAt.for(news_article))
        .merge(PayloadBuilder::PoliticalDetails.for(news_article))
        .merge(PayloadBuilder::TagDetails.for(news_article))
    end

    def emphasised_organisations
      news_article.lead_organisations.map(&:content_id)
    end

    def public_updated_at
      public_updated_at = (news_article.public_timestamp || news_article.updated_at)
      public_updated_at = if public_updated_at.respond_to?(:to_datetime)
                            public_updated_at.to_datetime
                          end

      public_updated_at.rfc3339
    end

    class ChangeHistory
      extend Forwardable

      def self.for(news_article)
        new(news_article).call
      end

      def initialize(news_article)
        self.news_article = news_article
      end

      def call
        return {} if change_history.blank?

        { change_history: change_history.as_json }
      end

    private

      attr_accessor :news_article
      def_delegator :news_article, :change_history
    end

    class Image
      extend Forwardable

      def self.for(news_article)
        new(news_article).call
      end

      def initialize(news_article)
        self.news_article = ::NewsArticlePresenter.new(news_article)
      end

      def call
        image_url = ActionController::Base.helpers.image_url(
          news_article.lead_image_path, host: Whitehall.public_asset_host
        )

        high_resolution_url = ActionController::Base.helpers.image_url(
          news_article.high_resolution_lead_image_path, host: Whitehall.public_asset_host
        )

        {
          image: {
            high_resolution_url: high_resolution_url,
            url: image_url,
            caption: image_caption,
            alt_text: image_alt_text,
          },
        }
      end

    private

      attr_accessor :news_article
      def_delegator :news_article, :lead_image_caption, :image_caption

      def image_alt_text
        news_article.lead_image_alt_text.squish
      end
    end
  end
end
