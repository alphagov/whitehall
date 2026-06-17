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
end
