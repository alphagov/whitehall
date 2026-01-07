require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderTopicalEventTest < ActiveSupport::TestCase
      setup do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("topical_event"))
        @publication = create(:publication)
        @topical_event = build(:topical_event)
        @topical_event_document = create(:standard_edition, configurable_document_type: "topical_event").document
        @publication.topical_events << @topical_event
        @publication.topical_event_documents << @topical_event_document
      end

      test "returns_content_ids_for_supplied_edition" do
        expected_result = { topical_events: [@topical_event.content_id, @topical_event_document.content_id] }
        actual_result = PublishingApi::PayloadBuilder::TopicalEvents.for(@publication)
        assert_equal expected_result, actual_result
      end
    end
  end
end
