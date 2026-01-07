require "test_helper"

class Admin::Editions::DocumentTypeChangeSummaryTest < ViewComponent::TestCase
  def build_type(label:, properties: {}, associations: [])
    OpenStruct.new(
      label: label,
      properties: properties,
      associations: associations,
    )
  end

  test "renders summary lists for lost and new fields and associations" do
    old_type = build_type(
      label: "Old type",
      properties: {
        "body" => { "title" => "Body" },
        "image" => { "title" => "Custom lead image" },
      },
      associations: [
        { "key" => "organisations" },
        { "key" => "world_locations" },
      ],
    )

    new_type = build_type(
      label: "New type",
      properties: {
        "summary" => { "title" => "Summary" },
        "body" => { "title" => "Body" },
      },
      associations: [
        { "key" => "organisations" },
        { "key" => "topical_events" },
      ],
    )

    edition = build(:draft_standard_edition)

    render_inline(
      Admin::Editions::DocumentTypeChangeSummary.new(
        edition: edition,
        old_type: old_type,
        new_type: new_type,
      ),
    )

    # Headings
    assert_text "Document fields"
    assert_text "Associations"

    # Lost field (image)
    assert_text "Custom lead image"
    assert_text "Will be deleted. A ‘New type’ does not have a ‘Custom lead image’ field."

    # New field (summary)
    assert_text "Summary"
    assert_text "Will need to be added. A ‘New type’ has a ‘Summary’ field. This field will be blank after the change."

    # Lost association (world_locations)
    assert_text "World locations"
    assert_text "Will be deleted. A ‘New type’ does not have a ‘World locations’ association."

    # New association (topical_events)
    assert_text "Topical events"
    assert_text "Will need to be added. A ‘New type’ has a ‘Topical events’ association. This field will be blank after the change."

    assert_text "Organisations"
    assert_text "These associations will be carried over, you will not have to fill them in again."
  end

  test "renders fallback messages when there are no changes" do
    type = build_type(
      label: "Same type",
      properties: {
        "body" => { "title" => "Body" },
      },
      associations: [
        { "key" => "organisations" },
      ],
    )

    edition = build(:draft_standard_edition)

    render_inline(
      Admin::Editions::DocumentTypeChangeSummary.new(
        edition: edition,
        old_type: type,
        new_type: type,
      ),
    )

    assert_text "Document fields"
    assert_text "All content in the document fields will be carried over. You will not have to add your content again."

    assert_text "Associations"
    assert_text "All associations will be carried over. You will not have to fill in the associations again."
  end

  test "handles missing properties and associations gracefully" do
    old_type = build_type(label: "Old type")
    new_type = build_type(label: "New type")

    edition = build(:draft_standard_edition)

    render_inline(
      Admin::Editions::DocumentTypeChangeSummary.new(
        edition: edition,
        old_type: old_type,
        new_type: new_type,
      ),
    )

    # Just check that we render the fallbacks and haven't crashed
    assert_text "Document fields"
    assert_text "Associations"
  end
end
