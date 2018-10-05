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
    end
  end
end
