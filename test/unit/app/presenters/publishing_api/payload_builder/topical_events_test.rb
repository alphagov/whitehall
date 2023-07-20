require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderTopicalEventTest < ActiveSupport::TestCase
      def setup
        @publication = create(:publication)
        @topical_event = build(:topical_event)
        @publication.topical_events << @topical_event
      end

      def test_returns_content_ids_for_supplied_edition
        expected_result = { topical_events: [@topical_event.content_id] }
        assert_equal expected_result, TopicalEvents.for(@publication)
      end
    end
  end
end
