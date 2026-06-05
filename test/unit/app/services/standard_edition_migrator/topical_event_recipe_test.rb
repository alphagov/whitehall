require "test_helper"

class TopicalEventRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @legacy_topical_event = create(:topical_event)
  end

  describe "#configurable_document_type" do
    test "is topical_event" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(@legacy_topical_event)
      assert_equal "topical_event", recipe.configurable_document_type
    end
  end

  describe "#presenter" do
    test "returns the correct presenter class" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(@legacy_topical_event)
      assert_equal PublishingApi::TopicalEventPresenter, recipe.presenter
    end
  end

  describe "#title" do
    test "returns the title of the topical event" do
      legacy_topical_event = create(:topical_event, name: "Sample Topical Event")
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(legacy_topical_event)
      assert_equal "Sample Topical Event", recipe.title(legacy_topical_event)
    end
  end

  describe "#summary" do
    test "returns the summary of the topical event" do
      legacy_topical_event = create(:topical_event, summary: "Sample Summary")
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(legacy_topical_event)
      assert_equal "Sample Summary", recipe.summary(legacy_topical_event)
    end
  end

  describe "#map_legacy_fields_to_block_content" do
    test "raises an exception if passed a Topical Event that has an About page - we're not ready to migrate those yet" do
      legacy_topical_event = create(:topical_event)
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(legacy_topical_event)

      create(:topical_event_about_page, topical_event: legacy_topical_event, read_more_link_text: "Read more about this event")

      assert_raises(WhitehallError) do
        recipe.map_legacy_fields_to_block_content(legacy_topical_event, legacy_topical_event)
      end
    end

    test "maps legacy fields to block content correctly" do
      legacy_topical_event = create(
        :topical_event,
        name: "Topical event title",
        description: "Sample body content",
        summary: "Sample summary",
      )
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(legacy_topical_event)
      block_content = recipe.map_legacy_fields_to_block_content(legacy_topical_event, legacy_topical_event)

      assert_equal "Sample body content", block_content["body"]
    end
  end

  describe "#ignore_legacy_content_fields" do
    test "removes 'start_date' as we're not carrying over duration fields to new topical events" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(@legacy_topical_event)
      content = { details: { some: "content", start_date: "2024-01-01" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    test "removes 'end_date' as we're not carrying over duration fields to new topical events" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(@legacy_topical_event)
      content = { details: { some: "content", end_date: "2024-01-01" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end
  end

  describe "#ignore_new_content_fields" do
    test "ignores 'auth_bypass_ids' as these were not present on legacy topical events and are included by default on StandardEdition" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(@legacy_topical_event)
      content = { details: { some: "content" }, auth_bypass_ids: [1, 2, 3] }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end

    test "ignores 'links' as legacy Topical Events had no edition links, but StandardEdition ones will" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(@legacy_topical_event)
      content = { details: { some: "content" }, links: { some: "links" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end

    test "ignores medium_resolution_url and high_resolution_url in each feature in ordered_featured_documents - these are new optional extra image variants in the StandardEdition featuring equivalent" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new(@legacy_topical_event)
      content = {
        details: {
          some: "content",
          ordered_featured_documents: [
            {
              title: "Featured document",
              image: {
                url: "http://example.com/image.jpg",
                medium_resolution_url: "http://example.com/image_medium.jpg",
                high_resolution_url: "http://example.com/image_high.jpg",
              },
            },
          ],
        },
      }
      expected_content = {
        details: {
          some: "content",
          ordered_featured_documents: [
            {
              title: "Featured document",
              image: {
                url: "http://example.com/image.jpg",
              },
            },
          ],
        },
      }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end
  end

  # TODO: Topical Event Featurings
  # TODO: Topical Event logo image
end
