require 'test_helper'

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderFirstPublicAtTest < ActiveSupport::TestCase
      def test_uses_first_published_at
        first_published_at = Object.new
        item = stub
        FirstPublishedAt.stubs(:for).with(item).returns(first_published_at: first_published_at)

        assert_equal(
          { first_public_at: first_published_at },
          FirstPublicAt.for(item)
        )
      end
    end
  end
end
