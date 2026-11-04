require "test_helper"

class TopicalEventAboutPageRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    topical_event_about_page_definition = JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/topical_event_about_page.json")))
    ConfigurableDocumentType.setup_test_types({
      "topical_event_about_page" => topical_event_about_page_definition,
    })
  end

  describe "#legacy_presenter" do
    it "returns the correct presenter class" do
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      assert_equal PublishingApi::TopicalEventAboutPagePresenter, recipe.legacy_presenter
    end
  end

  describe "#build_edition" do
    it "maps the basic legacy fields" do
      legacy_topical_event_about_page = create(
        :topical_event_about_page,
        name: "About",
        summary: "Sample summary",
        body: "Body goes here",
      )
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      edition = recipe.build_edition(legacy_topical_event_about_page)

      assert_equal "topical_event_about_page", edition.configurable_document_type
      assert_equal "About", edition.title
      assert_equal "Sample summary", edition.summary
    end

    it "sets the slug_override to 'about'" do
      legacy_topical_event_about_page = create(:topical_event_about_page)
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      edition = recipe.build_edition(legacy_topical_event_about_page)
      assert_equal "about", edition.slug_override
    end

    it "sets the creator as the Scheduled Publishing Robot" do
      create(:user, name: "Scheduled Publishing Robot")
      legacy_topical_event_about_page = create(:topical_event_about_page)
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      edition = recipe.build_edition(legacy_topical_event_about_page)
      assert_equal "Scheduled Publishing Robot", edition.creator.name
    end

    it "sets the state to published and major_change_published_at to the legacy created_at" do
      legacy_topical_event_about_page = create(:topical_event_about_page, created_at: 1.day.ago)
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      edition = recipe.build_edition(legacy_topical_event_about_page)
      assert_equal "published", edition.state
      assert_equal legacy_topical_event_about_page.created_at, edition.major_change_published_at
    end

    it "carries over the created_at and updated_at timestamps" do
      legacy_topical_event_about_page = create(
        :topical_event_about_page,
        created_at: 1.day.ago,
        updated_at: 1.hour.ago,
      )
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      edition = recipe.build_edition(legacy_topical_event_about_page)

      assert_equal legacy_topical_event_about_page.created_at, edition.created_at
      assert_equal legacy_topical_event_about_page.updated_at, edition.updated_at
    end

    it "maps the body to block_content" do
      legacy_topical_event_about_page = create(
        :topical_event_about_page,
        body: "Sample body content",
      )
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      edition = recipe.build_edition(legacy_topical_event_about_page)

      assert_equal("Sample body content", edition.block_content.to_h["body"])
    end
  end

  describe "#ignore_new_content_fields" do
    it "removes the auth_bypass_ids key from the content" do
      content = { auth_bypass_ids: [1, 2, 3], other_key: "value" }
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      recipe.ignore_new_content_fields(content)
      assert_not content.key?(:auth_bypass_ids)
      assert_equal "value", content[:other_key]
    end

    it "ignores the links key from the content" do
      content = { links: { some: "links" }, other_key: "value" }
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      recipe.ignore_new_content_fields(content)
      assert_not content.key?(:links)
      assert_equal "value", content[:other_key]
    end
  end

  describe "#ignore_legacy_content_fields" do
    it "removes the read_more key from the content details hash" do
      content = { details: { read_more: "Read more", some_key: "foo" }, other_key: "value" }
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      recipe.ignore_legacy_content_fields(content)
      assert_not content[:details].key?(:read_more)
      assert_equal "value", content[:other_key]
      assert_equal "foo", content[:details][:some_key]
    end

    it "converts public_updated_at to a string in the same format as the StandardEdition equivalent" do
      recipe = StandardEditionMigrator::TopicalEventAboutPageRecipe.new
      content = { public_updated_at: Time.zone.local(2024, 1, 1, 12, 0, 0) }
      expected_content = { public_updated_at: "2024-01-01T12:00:00+00:00" }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end
  end
end
