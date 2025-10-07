require "test_helper"

module PublishingApi::NewsArticlePresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :news_article, :update_type

    setup do
      create(:current_government)
    end

    def presented_news_article
      PublishingApi::NewsArticlePresenter.new(
        news_article,
        update_type:,
      )
    end

    def presented_content
      presented_news_article.content
    end

    def presented_links
      presented_news_article.links
    end

    def assert_attribute(attribute, value)
      assert_equal value, presented_content[attribute]
    end

    def assert_details_attribute(attribute, value)
      assert_equal value, presented_content[:details][attribute]
    end

    def assert_payload(builder, data: -> { presented_content })
      builder_double = builder.demodulize.underscore
      payload_double = { "#{builder_double}_key": "#{builder_double}_value" }

      builder
        .constantize
        .expects(:for)
        .at_least_once
        .with(news_article)
        .returns(payload_double)

      actual_data = data.call
      expected_data = actual_data.merge(payload_double)

      assert_equal expected_data, actual_data
    end

    def assert_details_payload(builder)
      assert_payload builder, data: -> { presented_content[:details] }
    end

    def assert_links_payload(builder)
      assert_payload builder, data: -> { presented_links }
    end
  end

  class BasicNewsArticleTest < TestCase
    include GovspeakHelper
    setup do
      self.news_article = create(:news_article)
    end

    test "base" do
      attributes_double = {
        base_attribute_one: "base_attribute_one",
        base_attribute_two: "base_attribute_two",
        base_attribute_three: "base_attribute_three",
      }

      PublishingApi::BaseItemPresenter
        .expects(:new)
        .with(news_article, update_type: "major")
        .returns(stub(base_attributes: attributes_double))

      actual_content = presented_content
      expected_content = actual_content.merge(attributes_double)

      assert_equal actual_content, expected_content
    end

    test "base links" do
      expected_link_keys = %i[
        organisations
        world_locations
        worldwide_organisations
        government
      ]

      links_double = {
        link_one: "link_one",
        link_two: "link_two",
        link_three: "link_three",
      }

      PublishingApi::PayloadBuilder::Links
        .expects(:new)
        .with(news_article)
        .returns(
          mock("PublishingApi::PayloadBuilder::Links").tap do |m|
            m.expects(:extract)
              .with(expected_link_keys)
              .returns(links_double)
          end,
        )

      actual_links = presented_links
      expected_links = actual_links.merge(links_double)

      assert_equal actual_links, expected_links
    end

    test "body details" do
      assert_details_attribute :body, govspeak_to_html(news_article.body)
    end

    test "access limitation" do
      assert_payload "PublishingApi::PayloadBuilder::AccessLimitation"
    end

    test "content id" do
      assert_equal news_article.content_id, presented_news_article.content_id
    end

    test "description" do
      assert_attribute :description, news_article.summary
    end

    test "emphasised organisations" do
      assert_details_attribute :emphasised_organisations,
                               news_article.lead_organisations.map(&:content_id)
    end

    test "first public at details" do
      assert_details_payload "PublishingApi::PayloadBuilder::FirstPublicAt"
    end

    test "first published at details" do
      assert_payload "PublishingApi::PayloadBuilder::FirstPublishedAt"
    end

    test "political details" do
      assert_details_payload "PublishingApi::PayloadBuilder::PoliticalDetails"
    end

    test "public document path" do
      assert_payload "PublishingApi::PayloadBuilder::PublicDocumentPath"
    end

    test "rendering app" do
      assert_attribute :rendering_app, news_article.rendering_app
    end

    test "schema name" do
      assert_attribute :schema_name, "news_article"
    end

    test "topical events" do
      assert_links_payload "PublishingApi::PayloadBuilder::TopicalEvents"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end

    test "auth bypass id" do
      assert_attribute :auth_bypass_ids, [news_article.auth_bypass_id]
    end
  end

  class WorldNewsStory < TestCase
    def setup
      self.news_article = create(:news_article_world_news_story)
    end

    test "includes worldwide organisation links" do
      news_article.worldwide_organisations = [create(:worldwide_organisation)]

      assert_equal news_article.worldwide_organisations.first.content_id, presented_news_article.links[:worldwide_organisations].first
    end
  end

  class GovernmentResponseTest < TestCase
    def setup
      self.news_article = create(:news_article_government_response)
    end

    test "document type" do
      assert_attribute :document_type, "government_response"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end

  class NewsStoryTest < TestCase
    def setup
      self.news_article = create(:news_article_news_story)
    end

    test "document type" do
      assert_attribute :document_type, "news_story"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end

  class PressReleaseTest < TestCase
    def setup
      self.news_article = create(:news_article_press_release)
    end

    test "document type" do
      assert_attribute :document_type, "press_release"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end

  class NewsArticleWithImage < TestCase
    test "send custom image as lead image" do
      expected_image_caption = "Baz"
      expected_image_alt_text = "Bar"
      image = create(:image, alt_text: expected_image_alt_text, caption: expected_image_caption)

      expected_image_payload = {
        high_resolution_url: image.image_data.file.url(:s960),
        url: image.image_data.file.url(:s300),
        caption: expected_image_caption,
        alt_text: expected_image_alt_text,
      }
      self.news_article = create(:news_article, lead_image: image)
      assert_equal expected_image_payload, presented_news_article.content[:details][:image]
    end

    test "does not send image information if lead image is not present" do
      self.news_article = create(:news_article)
      assert_nil news_article.lead_image
      assert_nil presented_news_article.content[:details][:image]

      worldwide_organisation = create(:published_worldwide_organisation, :with_default_news_image)
      self.news_article = create(:news_article_world_news_story, worldwide_organisations: [worldwide_organisation])
      assert_nil news_article.lead_image
      assert_nil presented_news_article.content[:details][:image]
    end

    test "should not send lead image if it doesn't have all assets" do
      image = create(:image)
      image.image_data.assets = []

      self.news_article = create(:news_article, lead_image: image)
      assert_nil presented_news_article.content[:details][:image]
    end
  end

  class NewsArticleWithMinisterialRoleAppointments < TestCase
    setup do
      self.news_article = create(
        :news_article,
        role_appointments: create_list(:ministerial_role_appointment, 2),
      )
    end

    test "roles" do
      expected_content_ids = news_article
        .role_appointments
        .map(&:role)
        .map(&:content_id)

      assert_equal presented_links[:roles], expected_content_ids
    end

    test "people" do
      expected_content_ids = news_article
        .role_appointments
        .map(&:person)
        .map(&:content_id)

      assert_equal presented_links[:people], expected_content_ids
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end

  class NewsArticleWithPublicTimestamp < TestCase
    setup do
      self.news_article = create(:published_news_article)

      news_article.stubs(
        public_timestamp: Date.new(1999),
        updated_at: Date.new(2012),
      )
    end

    test "public updated at" do
      assert_attribute :public_updated_at,
                       "1999-01-01T00:00:00+00:00"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end

  class NewsArticleWithoutPublicTimestamp < TestCase
    setup do
      self.news_article = create(:published_news_article)

      news_article.stubs(
        public_timestamp: nil,
        updated_at: Date.new(2012),
      )
    end

    test "public updated at" do
      assert_attribute :public_updated_at,
                       "2012-01-01T00:00:00+00:00"
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end

  class NewsArticleWithChangeHistory < TestCase
    setup do
      self.news_article = create(:published_news_article)
    end

    test "change history" do
      expected_change_history = [
        {
          "public_timestamp" => "2011-11-09T11:11:11.000+00:00",
          "note" => "change-note",
        },
      ]

      assert_details_attribute :change_history, expected_change_history
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end

  class NewsArticleWithMajorChange < TestCase
    setup do
      self.news_article = create(:news_article, minor_change: false)
      self.update_type = "major"
    end

    test "update type" do
      assert_equal "major", presented_news_article.update_type
    end
  end

  class NewsArticleWithMinorChange < TestCase
    setup do
      self.news_article = create(:news_article, minor_change: true)
    end

    test "update type" do
      assert_equal "minor", presented_news_article.update_type
    end
  end

  class NewsArticleWithoutMinorChange < TestCase
    setup do
      self.news_article = create(:news_article, minor_change: false)
    end

    test "update type" do
      assert_equal "major", presented_news_article.update_type
    end
  end

  class NewsArticleWithAttachments < TestCase
    setup do
      self.news_article = create(:news_article, :with_file_attachment)
    end

    test "attachment" do
      assert_equal presented_content.dig(:details, :attachments, 0, :id),
                   news_article.attachments.first.id.to_s
    end

    test "validity" do
      assert_valid_against_publisher_schema presented_content, "news_article"
      assert_valid_against_links_schema({ links: presented_links }, "news_article")
    end
  end
end
