require "test_helper"

class StandardEdition::HygieneEnforcerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    # Load the live schemas for these content types
    world_news_story_definition = JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/world_news_story.json")))
    news_story_definition = JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/news_story.json")))
    ConfigurableDocumentType.setup_test_types({
      "world_news_story" => world_news_story_definition,
      "news_story" => news_story_definition,
    })
  end

  describe "#cleanup" do
    context "cleaning up a document that has been converted into a world news story" do
      test "removes organisation associations and patches links with explicit empty array" do
        # Create a world news story that is mocked up to have been converted from a
        # news story (because it has organisations)
        edition = create(
          :standard_edition,
          configurable_document_type: "world_news_story",
          worldwide_organisations: [create(:worldwide_organisation)],
          world_locations: [create(:world_location)], # required for world news stories
          block_content: { body: "foo" },
          lead_organisations: [create(:organisation)], # this isn't usually set on World News Stories
        )

        # Assert that calling the hygiene enforcer removes the orgs and presents that downstream
        Services.publishing_api.expects(:patch_links).with(
          edition.document.content_id,
          links: has_entry(:organisations, []),
          bulk_publishing: false,
        )
        StandardEdition::HygieneEnforcer.new(edition).cleanup!
        assert edition.organisations.empty?
      end
    end
  end
end
