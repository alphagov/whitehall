module SyncChecker
  module Formats
    class WorldLocationNewsArticleCheck < EditionBase
      def checks_for_live(_locale)
        super.tap do |checks|
          checks << Checks::LinksCheck.new(
            'worldwide_organisations',
            expected_worldwide_organisation_content_ids,
          )
          checks << Checks::LinksCheck.new(
            'world_locations',
            expected_world_location_content_ids,
          )
        end
      end

      def expected_details_hash(world_location_news_article)
        super.tap do |details|
          details.merge!(expected_government(world_location_news_article))
          details.merge!(expected_image(world_location_news_article))
          details.merge!(expected_political(world_location_news_article))
          details.merge!(expected_tags(world_location_news_article))
          details.reject! { |k, _| k == :emphasised_organisations }
        end
      end

    private

      IMAGE_FORMAT = :s300
      IMAGE_PLACEHOLDER = '/placeholder.jpg'

      def document_type(_edition)
        'world_location_news_article'
      end

      def rendering_app
        Whitehall::RenderingApp::WHITEHALL_FRONTEND
      end

      def root_path
        '/government/world-location-news/'
      end

      def expected_government(world_location_news_article)
        return {} unless world_location_news_article.government

        {
          'government' => {
            'title' => world_location_news_article.government.name,
            'slug' => world_location_news_article.government.slug,
            'current' => world_location_news_article.government.current?
          }
        }
      end

      def expected_image(world_location_news_article)
        images = world_location_news_article.images
        lead_organisations = world_location_news_article.lead_organisations
        organisations = world_location_news_article.organisations
        worldwide_organisations = world_location_news_article.worldwide_organisations

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
                     elsif worldwide_organisations.any? && first_worldwide_organisation.default_news_image
                       first_worldwide_organisation.default_news_image.file.url(IMAGE_FORMAT)
                     else
                       IMAGE_PLACEHOLDER
                     end

        image_uri = URI(Whitehall.public_asset_host).tap do |uri|
          uri.path = image_path
        end

        {
          'image' => {
            'alt_text' => image_alt_text,
            'caption' => image_caption,
            'url' => image_uri.to_s,
          }
        }
      end

      def expected_political(world_location_news_article)
        { political: world_location_news_article.political? }
      end

      def expected_tags(world_location_news_article)
        topics = Array(world_location_news_article.primary_specialist_sector_tag) +
          world_location_news_article.secondary_specialist_sector_tags

        {
          'tags' => {
            'browse_pages' => [],
            'policies' => [],
            'topics' => topics.compact,
          }
        }
      end

      def expected_world_location_content_ids
        edition_expected_in_live.world_locations.map(&:content_id)
      end

      def expected_worldwide_organisation_content_ids
        edition_expected_in_live.worldwide_organisations.map(&:content_id)
      end
    end
  end
end
