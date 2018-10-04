require 'test_helper'

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderFirstPublicAtTest < ActiveSupport::TestCase
      def test_uses_first_published_at
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
          { first_public_at: first_published_at },
          FirstPublicAt.for(item)
        )
      end
    end
  end
end
