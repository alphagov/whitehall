require 'test_helper'

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderFirstPublishedAtTest < ActiveSupport::TestCase
      def test_returns_first_published_at_if_present
        first_published_at = Object.new
        item = stub(first_published_at: first_published_at)

        assert_equal(
          { first_published_at: first_published_at },
          FirstPublishedAt.for(item)
        )
      end

      def test_returns_document_created_at_for_nil_first_published_at
        created_at = Object.new
        item = stub(first_published_at: nil, document: stub(created_at: created_at))

        assert_equal(
          { first_published_at: created_at },
          FirstPublishedAt.for(item)
        )
      end
    end
  end
end
