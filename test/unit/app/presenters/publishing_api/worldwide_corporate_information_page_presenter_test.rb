require "test_helper"

module PublishingApi::WorldwideCorporateInformationPagePresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :corporate_information_page, :update_type

    def presented_corporate_information_page
      PublishingApi::WorldwideCorporateInformationPagePresenter.new(
        corporate_information_page,
        update_type:,
      )
    end

    class BasicCorporateInformationPageTest < TestCase
      setup do
        worldwide_organisation = create(:worldwide_organisation)
        self.corporate_information_page = create(:corporate_information_page, worldwide_organisation:, organisation: nil)
      end

      test "presents a Worldwide Corporate Information Page ready for adding to the publishing API" do
        public_path = corporate_information_page.public_path

        expected_hash = {
          base_path: public_path,
          title: corporate_information_page.title,
          schema_name: "worldwide_corporate_information_page",
          document_type: corporate_information_page.display_type_key,
          locale: "en",
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
          public_updated_at: corporate_information_page.updated_at,
          routes: [{ path: public_path, type: "exact" }],
          redirects: [],
          description: "edition-summary",
          details: {
            body: "<div class=\"govspeak\"><p>Some stuff</p>\n</div>",
          },
          update_type: "major",
        }

        expected_links = {
          parent: [
            corporate_information_page.owning_organisation.content_id,
          ],
          worldwide_organisation: [
            corporate_information_page.owning_organisation.content_id,
          ],
        }

        presented_item = presented_corporate_information_page

        assert_equal expected_hash, presented_item.content
        assert_hash_includes presented_item.links, expected_links
        assert_equal "major", presented_item.update_type
        assert_equal corporate_information_page.content_id, presented_item.content_id

        assert_valid_against_publisher_schema(presented_item.content, "worldwide_corporate_information_page")
        assert_valid_against_links_schema({ links: presented_item.links }, "worldwide_corporate_information_page")
      end
    end

    class CorporateInformationPageWithMinorChange < TestCase
      setup do
        self.corporate_information_page = create(
          :corporate_information_page,
          minor_change: true,
        )
      end

      test "update type" do
        assert_equal "minor", presented_corporate_information_page.update_type
      end
    end

    class CorporateInformationPageWithoutMinorChange < TestCase
      setup do
        self.corporate_information_page = create(
          :corporate_information_page,
          minor_change: false,
        )
      end

      test "update type" do
        assert_equal "major", presented_corporate_information_page.update_type
      end
    end
  end
end
