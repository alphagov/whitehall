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
    test "returns the correct presenter class" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      assert_equal PublishingApi::TopicalEventPresenter, recipe.legacy_presenter
    end
  end

  describe "#build_edition" do
    test "raises an exception if passed a Topical Event that has an About page - we're not ready to migrate those yet" do
      legacy_topical_event = create(:topical_event)
      recipe = StandardEditionMigrator::TopicalEventRecipe.new

      create(:topical_event_about_page, topical_event: legacy_topical_event, read_more_link_text: "Read more about this event")

      assert_raises(WhitehallError) do
        recipe.build_edition(legacy_topical_event)
      end
    end

    test "maps legacy fields to block content correctly" do
      legacy_topical_event = create(
        :topical_event,
        name: "Topical event title",
        description: "Sample body content",
        summary: "Sample summary",
      )
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      edition = recipe.build_edition(legacy_topical_event)

      assert_equal "Sample body content", edition.block_content["body"]
    end
  end

  describe "#ignore_legacy_content_fields" do
    test "converts public_updated_at to a string in the same format as the StandardEdition equivalent" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { public_updated_at: Time.zone.local(2024, 1, 1, 12, 0, 0) }
      expected_content = { public_updated_at: "2024-01-01T12:00:00+00:00" }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    test "removes .atom route as these are not present on StandardEdition documents and we have made a business decision to drop support for them" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: {}, routes: [{ path: "/government/topical-events/example" }, { path: "/government/topical-events/example.atom" }] }
      expected_content = { details: {}, routes: [{ path: "/government/topical-events/example" }] }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    test "removes 'start_date' as we're not carrying over duration fields to new topical events" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content", start_date: "2024-01-01" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    test "removes 'end_date' as we're not carrying over duration fields to new topical events" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content", end_date: "2024-01-01" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    test "calls 'chomp' on the old summary inside ordered_featured_documents because the StandardEdition equivalent removes stray spaces" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          ordered_featured_documents: [
            {
              summary: "Summary with trailing space ",
            },
          ],
        },
      }
      expected_content = {
        details: {
          ordered_featured_documents: [
            {
              summary: "Summary with trailing space",
            },
          ],
        },
      }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    test "puts summary through govspeak_to_html then ActionView::Base.full_sanitizer.sanitize as that's what the StandardEdition equivalent does" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          ordered_featured_documents: [
            {
              summary: "The UK's G8 is committed to support the recovery of stolen assets for the Arab Countries in Transition",
            },
          ],
        },
      }
      expected_content = {
        details: {
          ordered_featured_documents: [
            {
              summary: "The UK’s G8 is committed to support the recovery of stolen assets for the Arab Countries in Transition",
            },
          ],
        },
      }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end

    test "ignores 'URL' field inside ordered_featured_documents as the value is changed in the StandardEdition equivalent" do
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

    test "ignores 'image' field as this is replaced by 'images' array" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          image: {
            alt_text: "a",
            url: "http://example.com/image.jpg",
          },
        },
      }
      expected_content = {
        details: {},
      }
      assert_equal expected_content, recipe.ignore_legacy_content_fields(content)
    end
  end

  describe "#ignore_new_content_fields" do
    test "ignores 'auth_bypass_ids' as these were not present on legacy topical events and are included by default on StandardEdition" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content" }, auth_bypass_ids: [1, 2, 3] }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end

    test "ignores 'links' as legacy Topical Events had no edition links, but StandardEdition ones will" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = { details: { some: "content" }, links: { some: "links" } }
      expected_content = { details: { some: "content" } }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end

    test "ignores medium_resolution_url and high_resolution_url in each feature in ordered_featured_documents - these are new optional extra image variants in the StandardEdition featuring equivalent" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          some: "content",
          ordered_featured_documents: [
            {
              title: "Featured document",
              image: {
                alt_text: "a",
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
                alt_text: "a",
              },
            },
          ],
        },
      }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end

    test "ignores 'URL' field inside ordered_featured_documents as the value is changed in the StandardEdition equivalent" do
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

    test "ignores 'images' field as this replaces the old 'image' field" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      content = {
        details: {
          some: "content",
          images: [
            {
              alt_text: "a",
              url: "http://example.com/image.jpg",
            },
          ],
        },
      }
      expected_content = {
        details: {
          some: "content",
          # images field is ignored as this replaces the old image field in the StandardEdition equivalent
        },
      }
      assert_equal expected_content, recipe.ignore_new_content_fields(content)
    end
  end

  describe "#ignore_new_links" do
    test "ignores emphasised_organisations - these are not present on legacy topical events and are included by default on StandardEdition" do
      recipe = StandardEditionMigrator::TopicalEventRecipe.new
      links = { emphasised_organisations: [1, 2, 3], some: "links" }
      expected_links = { some: "links" }
      assert_equal expected_links, recipe.ignore_new_links(links)
    end
  end

  # TODO: Topical Event Featurings
  # TODO: Topical Event logo image
end
