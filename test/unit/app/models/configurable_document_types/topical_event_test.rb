require "test_helper"

class TopicalEventTest < ActiveSupport::TestCase
  setup do
    path = Rails.root.join("app/models/configurable_document_types/topical_event.json")
    ConfigurableDocumentType.setup_test_types({
      "topical_event" => JSON.parse(path.read),
    })
    @edition_attributes = {
      title: "A topical event",
      summary: "Summary of topical event",
      previously_published: false,
      configurable_document_type: "topical_event",
      creator: create(:user),
      lead_organisations: [create(:organisation)],
    }
  end

  test "duration is valid when start and end dates are blank" do
    topical_event = StandardEdition.new(
      @edition_attributes.merge(
        block_content: {
          body: "foo",
          duration: { "start_date" => "", "end_date" => "" },
        },
      ),
    )
    assert topical_event.valid?
  end

  test "duration is invalid when end date is before start date" do
    topical_event = StandardEdition.new(
      @edition_attributes.merge(
        block_content: {
          body: "foo",
          # TODO: are these values correct? Should they be timestamps? etc
          duration: { "start_date" => "2024-01-02", "end_date" => "2024-01-01" },
        },
      ),
    )
    assert topical_event.invalid?
    # TODO: something like this
    assert_equal ["End date must be on or after start date"], topical_event.errors
  end
end
