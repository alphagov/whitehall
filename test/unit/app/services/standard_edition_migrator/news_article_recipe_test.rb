require "test_helper"

class NewsArticleRecipeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#configurable_document_type" do
    test "raises an error" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      assert_raises(RuntimeError, "NewsArticleRecipe should not be used directly. Use a subtype recipe instead.") do
        recipe.configurable_document_type
      end
    end
  end

  describe "#presenter" do
    test "returns the correct presenter class" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      assert_equal PublishingApi::NewsArticlePresenter, recipe.presenter
    end
  end

  describe "#map_legacy_fields_to_block_content" do
    test "maps legacy fields to block content correctly" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      edition = create(:news_article, body: "Sample body content", lead_image: build(:image))
      block_content = recipe.map_legacy_fields_to_block_content(edition, edition.translations.first)

      assert_equal "Sample body content", block_content["body"]
      assert_equal edition.lead_image.image_data_id, block_content["image"]
    end

    test "omits lead_image if one isn't set" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      edition = create(:news_article, lead_image: nil)
      block_content = recipe.map_legacy_fields_to_block_content(edition, edition.translations.first)

      assert_nil block_content["image"]
    end
  end

  describe "#ignore_legacy_content_fields" do
    # No `first_public_at` property, which is just a
    # [duplication](https://github.com/alphagov/whitehall/blob/aa9cdc7d53e68f1bf75443e60d7d3186534208de/app/presenters/publishing_api/payload_builder/first_public_at.rb#L9)
    # of the existing `first_published_at` property.
    # It wasn't carried over to Content Publisher and is
    # [considered deprecated](https://github.com/alphagov/content-publisher/blob/7a999c738bb982db267a23577af80db66a66312d/docs/adr/0016-publishing-times-and-change-history.md?plain=1#L40).
    # government-frontend [falls back to first_published_at](https://github.com/alphagov/government-frontend/blob/f38f22922249a57e9df5ec9fe9a520ad91e8b0dd/app/presenters/content_item/updatable.rb#L18),
    # as does Frontend ([for detailed guides](https://github.com/alphagov/frontend/blob/10bd509470017853ec103c075cb9bfcc54d067ca/app/views/detailed_guide/show.html.erb#L41) - but
    # [not for case studies](https://github.com/alphagov/frontend/blob/10bd509470017853ec103c075cb9bfcc54d067ca/app/views/case_study/show.html.erb#L65))
    # One can imagine how any rendering app references to `first_public_at`
    # can be swapped out for `first_published_at`.
    test "removes first_public_at from content details" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      content = {
        details: {
          first_public_at: "2023-01-01T00:00:00Z",
          other_field: "value",
        },
      }

      updated_content = recipe.ignore_legacy_content_fields(content)

      assert_not_includes updated_content[:details].keys, :first_public_at
      assert_equal "value", updated_content[:details][:other_field]
    end

    # alt text is deprecated (as all Whitehall images are 'decorative')
    # and is being fully removed in the near future
    test "removes alt_text from lead image in content details" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      content = {
        details: {
          image: {
            url: "http://example.com/image.jpg",
            caption: "Foo",
            alt_text: "An example image",
          },
          other_field: "value",
        },
      }
      updated_content = recipe.ignore_legacy_content_fields(content)
      assert_not_includes updated_content[:details][:image].keys, :alt_text
      assert_equal "http://example.com/image.jpg", updated_content[:details][:image][:url]
      assert_equal "Foo", updated_content[:details][:image][:caption]
      assert_equal "value", updated_content[:details][:other_field]
    end

    test "removes caption from lead image in content details if caption is nil" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      content = {
        details: {
          image: {
            url: "http://example.com/image.jpg",
            caption: nil,
          },
          other_field: "value",
        },
      }
      updated_content = recipe.ignore_legacy_content_fields(content)
      assert_not_includes updated_content[:details][:image].keys, :caption
      assert_equal "http://example.com/image.jpg", updated_content[:details][:image][:url]
      assert_equal "value", updated_content[:details][:other_field]
    end

    # No `tags` (`{ browse_pages: [] }`) property, which has been
    # [recognised as legacy and unused](https://github.com/alphagov/email-alert-api/pull/2136#discussion_r1594207581).
    test "removes tags from content details, if the tags are only `browse_pages`" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      content = {
        details: {
          tags: { browse_pages: %w[page1 page2] },
          other_field: "value",
        },
      }

      updated_content = recipe.ignore_legacy_content_fields(content)

      assert_not_includes updated_content[:details].keys, :tags
      assert_equal "value", updated_content[:details][:other_field]
    end

    # If there are other tags present, we should retain them.
    test "retains tags from content details, if the tags include more than just `browse_pages`" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      content = {
        details: {
          tags: { browse_pages: %w[page1], topics: %w[topic1] },
          other_field: "value",
        },
      }

      updated_content = recipe.ignore_legacy_content_fields(content)

      assert_includes updated_content[:details].keys, :tags
      assert_equal({ topics: %w[topic1] }, updated_content[:details][:tags])
      assert_equal "value", updated_content[:details][:other_field]
    end
  end

  describe "#ignore_new_content_fields" do
    # We now send `links` as part of the content payload because we want to avoid
    # using linkset links altogether. Edition links are missing recursive expansion
    # but we can figure out what to do about that later.
    test "adds `links` to the content payload" do
      recipe = StandardEditionMigrator::NewsArticleRecipe.new
      content = {
        details: {
          other_field: "value",
        },
        links: {
          foo: %w[bar],
        },
      }
      updated_content = recipe.ignore_new_content_fields(content)
      assert_not_includes updated_content.keys, :links
      assert_equal "value", updated_content[:details][:other_field]
    end
  end
end
