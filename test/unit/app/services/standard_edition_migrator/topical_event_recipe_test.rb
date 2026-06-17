require "test_helper"

class TopicalEventRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @legacy_topical_event = create(:topical_event)
    topical_event_definition = JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/topical_event.json")))
    ConfigurableDocumentType.setup_test_types({
      "topical_event" => topical_event_definition,
    })
  end

  describe "#legacy_presenter" do
    it "returns the correct presenter class" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      assert_equal PublishingApi::TopicalEventPresenter, recipe.legacy_presenter
    end
  end

  describe "#build_edition" do
    it "raises an exception if passed a Topical Event that has an About page - we're not ready to migrate those yet" do
      legacy_topical_event = create(:topical_event)
      recipe = StandardEditionMigrator::TopicalEventRecipe.new

      create(:topical_event_about_page, topical_event: legacy_topical_event, read_more_link_text: "Read more about this event")

      assert_raises(WhitehallError) do
        recipe.build_edition(legacy_topical_event)
      end
    end

    it "maps the basic legacy fields" do
      legacy_topical_event = create(
        :topical_event,
        name: "Topical event title",
        summary: "Sample summary",
      )
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      assert_equal "topical_event", edition.configurable_document_type
      assert_equal "Topical event title", edition.title
      assert_equal "Sample summary", edition.summary
    end

    it "maps the body to block_content" do
      legacy_topical_event = create(
        :topical_event,
        description: "Sample body content",
      )
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      assert_equal("Sample body content", edition.block_content.to_h["body"])
    end
  end
end
