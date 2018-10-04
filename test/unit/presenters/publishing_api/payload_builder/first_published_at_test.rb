require 'test_helper'

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderFirstPublishedAtTest < ActiveSupport::TestCase
      def test_returns_first_published_at_if_present
        first_published_at = Date.new(2000, 1, 1)

        document = build(:document)
        item = build(
          :published_edition,
          document: document,
          first_published_at: first_published_at
        )
        document.stubs(:published_edition).returns(item)
        document.stubs(:reload_published_edition).returns(item)

        assert_equal(
          { first_published_at: first_published_at },
          FirstPublishedAt.for(item)
        )
      end

      def test_returns_document_created_at_for_nil_first_published_at
        created_at = Date.new(2000, 1, 1)

        document = build(:document, created_at: created_at)
        item = build(
          :published_edition,
          document: document,
          first_published_at: nil
        )
        document.stubs(:published_edition).returns(item)
        document.stubs(:reload_published_edition).returns(item)

        assert_equal(
          { first_published_at: created_at },
          FirstPublishedAt.for(item)
        )
      end
    end
  end
end
