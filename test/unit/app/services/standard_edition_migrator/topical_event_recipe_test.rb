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

    it "sets the creator as the Scheduled Publishing Robot" do
      create(:user, name: "Scheduled Publishing Robot")
      legacy_topical_event = create(:topical_event)
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)
      assert_equal "Scheduled Publishing Robot", edition.creator.name
    end

    it "sets the state to published and major_change_published_at to the legacy created_at" do
      legacy_topical_event = create(:topical_event, created_at: 1.day.ago)
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)
      assert_equal "published", edition.state
      assert_equal legacy_topical_event.created_at, edition.major_change_published_at
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

    it "creates a non-empty body for the new edition, even if the legacy record has no body" do
      legacy_topical_event = create(
        :topical_event,
        description: "Sample body content",
      )
      legacy_topical_event.description = nil
      legacy_topical_event.save!(validate: false)

      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      assert_equal "&nbsp;", edition.block_content.to_h["body"]
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

    it "increments the social media title if more than one link is present for the same service" do
      legacy_topical_event = create(:topical_event)
      legacy_topical_event.social_media_accounts = [
        create(
          :social_media_account,
          social_media_service: SocialMediaService.new(name: "Facebook"),
          url: "https://www.facebook.com",
          title: "Facebook link",
        ),
        create(
          :social_media_account,
          social_media_service: SocialMediaService.new(name: "Facebook"),
          url: "https://www.facebook.com/2",
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
        {
          "social_media_service_name" => "Facebook",
          "url" => "https://www.facebook.com/2",
          "title" => "Facebook link (2)",
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
      recipe.after_save_edition(edition, legacy_topical_event)
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

    it "carries over legacy topical_event_memberships as topical_event_links" do
      # In addition to the new topical_event StandardEdition type, we
      # need to define a document type that has the Edition::TopicalEvent concern included.
      test_type_with_topical_event_association = build_configurable_document_type("test_type", { "associations" => [
        {
          "key" => "topical_event_documents",
        },
      ] })

      topical_event_definition = JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/topical_event.json")))
      ConfigurableDocumentType.setup_test_types({
        "topical_event" => topical_event_definition,
      }.merge(test_type_with_topical_event_association))

      associated_edition = create(:standard_edition, :with_document)
      associated_document = associated_edition.document
      legacy_topical_event = create(:topical_event)
      create(
        :topical_event_membership,
        topical_event_id: legacy_topical_event.id,
        edition_id: associated_edition.id,
      )
      legacy_topical_event.save!

      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      standard_edition_topical_event = recipe.build_edition(legacy_topical_event)

      # Needed to create and save the document before we can create the EditionLink association
      standard_edition_topical_event.document = create(:document)
      standard_edition_topical_event.save!(validate: false)
      recipe.after_save_edition(standard_edition_topical_event, legacy_topical_event)

      # The `edition` is the linked document. The `document` is the topical event.
      # #<EditionLink:0x0000ffff624f8fc8
      #  edition_id: 1708834,
      #  document_id: 619491,
      #  link_type: "topical_event">

      assert_equal 1, associated_document.latest_edition.topical_event_links.count
      assert_equal "topical_event", associated_document.latest_edition.topical_event_links.first.link_type
      assert_equal standard_edition_topical_event.document.id, associated_document.latest_edition.topical_event_links.first.document.id
      assert_equal standard_edition_topical_event.document.id, associated_document.latest_edition.topical_event_documents.first.id
    end

    it "carries over the Logo" do
      legacy_topical_event = create(:topical_event)
      legacy_logo = create(:featured_image_data, featured_imageable: legacy_topical_event)
      legacy_topical_event.logo = legacy_logo
      legacy_topical_event.save!

      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      # Needed to persist the Logo and create IDs etc
      edition.document = create(:document)
      edition.save!(validate: false)
      recipe.after_save_edition(edition, legacy_topical_event)
      edition.reload # to ensure everything has persisted

      assert_equal [
        ["asset_manager_id_original", "original", "minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s960", "s960", "s960_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s712", "s712", "s712_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s630", "s630", "s630_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s465", "s465", "s465_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s300", "s300", "s300_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s216", "s216", "s216_minister-of-funk.960x640.jpg"],
      ], legacy_logo.assets.pluck(:asset_manager_id, :variant, :filename)

      assert_equal [
        ["asset_manager_id_s960", "original", "s960_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s960", "topical_event_logo_mobile", "s960_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s960", "topical_event_logo_mobile_2x", "s960_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s960", "topical_event_logo_tablet", "s960_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s960", "topical_event_logo_tablet_2x", "s960_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s960", "topical_event_logo_desktop", "s960_minister-of-funk.960x640.jpg"],
        ["asset_manager_id_s960", "topical_event_logo_desktop_2x", "s960_minister-of-funk.960x640.jpg"],
      ], edition.images.first.image_data.assets.pluck(:asset_manager_id, :variant, :filename)

      assert_equal "logo", edition.images.first.usage
      assert_equal "topical_event_logo", edition.images.first.image_data.image_kind
      dimensions = { "width" => 1506, "height" => 960 }
      crop_data = { "x" => 0, "y" => 0, "width" => 1506, "height" => 1004 }
      assert_equal dimensions, edition.images.first.image_data.dimensions
      assert_equal crop_data, edition.images.first.image_data.crop_data
    end
  end

  describe "#ignore_legacy_content_fields" do
    it "removes .atom route as these are not present on StandardEdition documents and we have made a business decision to drop support for them" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: {}, routes: [{ path: "/government/topical-events/example" }, { path: "/government/topical-events/example.atom" }] }
      expected_content = { details: {}, routes: [{ path: "/government/topical-events/example" }] }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    it "removes 'start_date' as we're not carrying over duration fields to new topical events" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content", start_date: "2024-01-01" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    it "removes 'end_date' as we're not carrying over duration fields to new topical events" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content", end_date: "2024-12-31" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    it "ignores 'URL' field inside ordered_featured_documents as the value is changed in the StandardEdition equivalent" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          some: "content",
          ordered_featured_documents: [
            {
              title: "Featured document",
              image: {
                url: "http://example.com/image.jpg",
                foo: "bar",
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
                foo: "bar",
              },
            },
          ],
        },
      }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    it "sanitizes the summary field inside ordered_featured_documents, like the StandardEdition equivalent" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          ordered_featured_documents: [
            {
              summary: "The UK's G8 is committed to support ", # NOTE: the trailing space
            },
          ],
        },
      }
      expected_content = {
        details: {
          ordered_featured_documents: [
            {
              summary: "The UK’s G8 is committed to support", # NOTE: the stripped space and the non-ascii quote
            },
          ],
        },
      }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    it "converts public_updated_at to a string in the same format as the StandardEdition equivalent" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { public_updated_at: Time.zone.local(2024, 1, 1, 12, 0, 0) }
      expected_content = { public_updated_at: "2024-01-01T12:00:00+00:00" }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    it "ignores 'image' property - now replaced by 'images' array" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content", image: { url: "http://example.com/image.jpg" } } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    it "ignores where we have defaulted the body to a value of '&nbsp;'" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { body: "<div class=\"govspeak\">\n</div>" } }
      expected_content = { details: { body: "<div class=\"govspeak\"><p>&nbsp;</p>\n</div>" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end
  end

  describe "#ignore_new_content_fields" do
    it "ignores 'auth_bypass_ids' as these were not present on legacy topical events and are included by default on StandardEdition" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content" }, auth_bypass_ids: [1, 2, 3] }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end

    it "ignores 'links' as legacy Topical Events had no edition links, but StandardEdition ones will" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content" }, links: { some: "links" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end

    it "ignores 'details.images' array (replacing old 'image' property)" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content", images: [{ url: "http://example.com/image.jpg" }] } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end
  end

  describe "#ignore_new_links" do
    it "ignores 'emphasised_organisations' as these are not present on legacy topical events and are included by default on StandardEdition" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      links = { lead_organisations: [1, 2], emphasised_organisations: [3, 4] }
      expected_links = { lead_organisations: [1, 2] }
      assert_equal expected_links, recipe.ignore_new_links(links)
    end

    it "ignores 'URL' field inside ordered_featured_documents as the value is changed in the StandardEdition equivalent" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          some: "content",
          ordered_featured_documents: [
            {
              title: "Featured document",
              image: {
                url: "http://example.com/image.jpg",
                foo: "bar",
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
                foo: "bar",
              },
            },
          ],
        },
      }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end
  end
end
