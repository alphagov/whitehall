require "test_helper"
require "json/add/symbol"

class TopicalEventTest < ActiveSupport::TestCase
  setup do
    path = Rails.root.join("app/models/configurable_document_types/topical_event.json")
    ConfigurableDocumentType.setup_test_types({
      "topical_event" => JSON.parse(path.read, create_additions: true),
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
          duration: { "start_date" => "2024-01-02", "end_date" => "2024-01-01" },
        },
      ),
    )
    assert topical_event.invalid?
    assert_includes topical_event.errors.full_messages, "Duration end date must be greater than or equal to 2024-01-02"
  end

  test "duration is invalid when start date is empty and end date is populated" do
    topical_event = StandardEdition.new(
      @edition_attributes.merge(
        block_content: {
          body: "foo",
          duration: { "start_date" => nil, "end_date" => "2024-01-01" },
        },
      ),
    )
    assert topical_event.invalid?
    assert_includes topical_event.errors.full_messages, "Duration end date must be greater than or equal to 2024-01-02"
  end

  test "duration is valid when end date is after start date" do
    topical_event = StandardEdition.new(
      @edition_attributes.merge(
        block_content: {
          body: "foo",
          duration: { "start_date" => "2024-01-01", "end_date" => "2024-01-02" },
        },
      ),
    )
    assert topical_event.valid?
  end
end
