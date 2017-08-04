module SyncChecker
  module Formats
    class NewsArticleCheck < EditionBase
      def expected_details_hash(news_article, _)
        super.tap do |details|
          details.except!(:change_history) unless news_article.change_history.present?
          details.merge!(expected_government(news_article))
          details.merge!(expected_image(news_article))
          details.merge!(expected_political(news_article))
          details.merge!(expected_tags(news_article))
        end
      end

      def checks_for_live(_locale)
        super.tap do |checks|
          checks << Checks::LinksCheck.new('ministers',
                                           expected_minister_content_ids)
          checks << Checks::LinksCheck.new(
            'worldwide_organisations',
            expected_worldwide_organisation_content_ids,
          )
        end
      end

    private

      IMAGE_FORMAT = :s300
      IMAGE_PLACEHOLDER = 'placeholder.jpg'
      LENGTH_OF_FRACTIONAL_SECONDS = 3

      def document_type(news_article)
        news_article.display_type_key
      end

      def first_public_at(news_article)
        (news_article.first_published_at || news_article.document.created_at)
          .to_datetime
          .rfc3339(LENGTH_OF_FRACTIONAL_SECONDS)
      end

      def rendering_app
        Whitehall::RenderingApp::GOVERNMENT_FRONTEND
      end

      def root_path
        '/government/news/'
      end

      def expected_government(news_article)
        return {} unless news_article.government

        {
          'government' => {
            'title' => news_article.government.name,
            'slug' => news_article.government.slug,
            'current' => news_article.government.current?
          }
        }
      end

      def expected_image(news_article)
        images = news_article.images
        lead_organisations = news_article.lead_organisations
        organisations = news_article.organisations
        worldwide_organisations = news_article.worldwide_organisations

        first_image = images.first
        first_lead_organisation = lead_organisations.first
        first_organisation = organisations.first
        first_worldwide_organisation = worldwide_organisations.first

        image_alt_text = if first_image
                           first_image.alt_text.squish
                         else
                           'placeholder'
                         end

        image_caption = first_image.try(:caption).try(:strip).presence

        image_path = if first_image
                       first_image.url(IMAGE_FORMAT)
                     elsif lead_organisations.any? && first_lead_organisation.default_news_image
                       first_lead_organisation.default_news_image.file.url(IMAGE_FORMAT)
                     elsif organisations.any? && first_organisation.default_news_image
                       first_organisation.default_news_image.file.url(IMAGE_FORMAT)
                     elsif first_worldwide_organisation && first_worldwide_organisation.default_news_image
                       worldwide_organisations.first.default_news_image.file.url(IMAGE_FORMAT)
                     else
                       IMAGE_PLACEHOLDER
                     end

        image_uri = ActionController::Base.helpers.image_url(
          image_path, host: Whitehall.public_asset_host,
        )

        {
          'image' => {
            'alt_text' => image_alt_text,
            'caption' => image_caption,
            'url' => image_uri,
          }
        }
      end

      def expected_minister_content_ids
        edition_expected_in_live
          .role_appointments
          .try(:collect, &:person)
          .try(:collect, &:content_id)
      end

      def expected_political(news_article)
        { political: news_article.political? }
      end

      def expected_tags(news_article)
        policies = if news_article.can_be_related_to_policies?
                     news_article.policies.map(&:slug)
                   end

        topics = Array(news_article.primary_specialist_sector_tag) +
          news_article.secondary_specialist_sector_tags

        {
          'tags' => {
            'browse_pages' => [],
            'policies' => (policies || []).compact,
            'topics' => topics.compact,
          }
        }
      end

      def expected_worldwide_organisation_content_ids
        edition_expected_in_live.worldwide_organisations.map(&:content_id)
      end
    end
  end
end
