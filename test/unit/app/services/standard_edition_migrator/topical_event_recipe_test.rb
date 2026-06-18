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

    it "carries over the created_at and updated_at timestamps" do
      legacy_topical_event = create(
        :topical_event,
        created_at: 1.day.ago,
        updated_at: 1.hour.ago,
      )
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      assert_equal legacy_topical_event.created_at, edition.created_at
      assert_equal legacy_topical_event.updated_at, edition.updated_at
    end

    it "maps the slug to slug_override" do
      legacy_topical_event = create(
        :topical_event,
        name: "Topical event title",
        slug: "topical-event-slug-that-is-different-from-the-title",
      )
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      assert_equal "topical-event-slug-that-is-different-from-the-title", edition.slug_override
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

    it "carries over social media links to block_content" do
      legacy_topical_event = create(:topical_event)
      legacy_topical_event.social_media_accounts = [
        create(
          :social_media_account,
          social_media_service: SocialMediaService.new(name: "Facebook"),
          url: "https://www.facebook.com",
          title: "Facebook link",
        ),
      ]
      legacy_topical_event.save!
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      assert_equal([
        {
          "social_media_service_name" => "Facebook",
          "url" => "https://www.facebook.com",
          "title" => "Facebook link",
        },
      ], edition.block_content.to_h["social_media_links"])
    end

    it "carries over lead and supporting organisations" do
      legacy_topical_event = create(:topical_event)
      lead_organisation = create(:organisation)
      supporting_organisation = create(:organisation)
      legacy_topical_event.topical_event_organisations = [
        create(:topical_event_organisation, lead: true, organisation: lead_organisation),
        create(:topical_event_organisation, lead: false, organisation: supporting_organisation),
      ]
      legacy_topical_event.save!

      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)
      edition.document = create(:document)
      edition.save!(validate: false)
      edition.reload

      assert_equal [lead_organisation], edition.lead_organisations
      assert_equal [supporting_organisation], edition.supporting_organisations
    end

    it "carries over Features (legacy term: Featurings) and their thumbnails" do
      legacy_topical_event = create(:topical_event)
      legacy_govuk_content_featuring = create(:topical_event_featuring, ordering: 1)
      legacy_offsite_link_featuring = create(:offsite_topical_event_featuring, ordering: 2)
      legacy_topical_event.topical_event_featurings = [
        legacy_govuk_content_featuring,
        legacy_offsite_link_featuring,
      ]
      legacy_topical_event.save!

      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      # Needed to persist the Features and create IDs etc
      edition.document = create(:document)
      edition.save!(validate: false)
      recipe.save_artefacts!(validate: false, edition: edition)
      edition.reload # to ensure everything has persisted
      govuk_content_feature = edition.feature_lists.first.features.first
      offsite_link_feature = edition.feature_lists.first.features.second

      # TopicalEventFeaturing -> Featurable
      assert_equal legacy_govuk_content_featuring.edition.document, govuk_content_feature.document
      assert_equal legacy_govuk_content_featuring.alt_text, govuk_content_feature.alt_text
      assert_equal legacy_govuk_content_featuring.ordering, govuk_content_feature.ordering
      assert_equal legacy_offsite_link_featuring.offsite_link, offsite_link_feature.offsite_link
      assert_equal legacy_offsite_link_featuring.alt_text, offsite_link_feature.alt_text
      assert_equal legacy_offsite_link_featuring.ordering, offsite_link_feature.ordering

      # TopicalEventFeaturingImageData -> FeaturedImageData
      assert_equal legacy_govuk_content_featuring.image.filename, govuk_content_feature.image.filename
      assert_equal legacy_offsite_link_featuring.image.filename, offsite_link_feature.image.filename
      assert_equal 7, govuk_content_feature.image.assets.size
      assert_equal 7, offsite_link_feature.image.assets.size
    end
  end
end
