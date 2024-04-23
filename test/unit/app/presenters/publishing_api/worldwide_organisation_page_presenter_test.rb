require "test_helper"

module PublishingApi::WorldwideOrganisationPagePresenterTest
  class TestCase < ActiveSupport::TestCase
    attr_accessor :page, :update_type

    def presented_page
      PublishingApi::WorldwideOrganisationPagePresenter.new(
        page,
        update_type:,
      )
    end

    class BasicWorldwideOrganisationPageTest < TestCase
      test "presents a Worldwide Organisation Page ready for adding to the publishing API" do
        self.page = create(:worldwide_organisation_page)

        public_path = page.public_path

        expected_hash = {
          base_path: public_path,
          title: page.title,
          schema_name: "worldwide_corporate_information_page",
          document_type: page.display_type_key,
          locale: "en",
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
          public_updated_at: page.updated_at.rfc3339,
          routes: [{ path: public_path, type: "exact" }],
          redirects: [],
          description: "Some summary",
          details: {
            body: "<div class=\"govspeak\"><p>Some body</p>\n</div>",
          },
          update_type: "major",
          links: {
            parent: [page.edition.content_id],
            worldwide_organisation: [page.edition.content_id],
          },
        }

        expected_links = {
          parent: [
            page.edition.content_id,
          ],
          worldwide_organisation: [
            page.edition.content_id,
          ],
        }

        presented_item = presented_page

        assert_equal expected_hash, presented_item.content
        assert_hash_includes presented_item.edition_links, expected_links
        assert_equal "major", presented_item.update_type
        assert_equal page.content_id, presented_item.content_id

        assert_valid_against_publisher_schema(presented_item.content, "worldwide_corporate_information_page")
        assert_valid_against_links_schema({ links: presented_item.edition_links }, "worldwide_corporate_information_page")
      end

      test "presents the correct routes for a Worldwide Organisation Page with a translation" do
        self.page = create(:worldwide_organisation_page, translated_into: [:fr])

        I18n.with_locale(:en) do
          presented_item = PublishingApi::WorldwideOrganisationPagePresenter.new(page)

          assert_equal page.base_path, presented_item.content[:base_path]

          assert_equal [
            { path: page.base_path, type: "exact" },
          ], presented_item.content[:routes]
        end

        I18n.with_locale(:fr) do
          presented_item = PublishingApi::WorldwideOrganisationPagePresenter.new(page)

          assert_equal "#{page.base_path}.fr", presented_item.content[:base_path]

          assert_equal [
            { path: "#{page.base_path}.fr", type: "exact" },
          ], presented_item.content[:routes]
        end
      end
    end
  end
end
