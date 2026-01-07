require "test_helper"

class Admin::Editions::DocumentTypeChangeSummaryTest < ViewComponent::TestCase
  def build_type(label:, properties: {}, associations: [])
    ConfigurableDocumentType.new({
      "title" => label,
      "schema" => {
        "properties" => properties,
      },
      "associations" => associations,
    })
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
    assert_text "Will be LOST - this field exists on “Old type” but not on “New type”."

    # New field (summary)
    assert_text "Summary"
    assert_text "Will need POPULATING - this field exists on “New type” but not on “Old type”."

    # Lost association (world_locations)
    assert_text "World locations"
    assert_text "Will be LOST - this association exists on “Old type” but not on “New type”."

    # New association (topical_events)
    assert_text "Topical events"
    assert_text "Will need POPULATING - this association exists on “New type” but not on “Old type”."
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
    assert_text "All document fields will be carried over and no additional document fields will need to be populated."

    assert_text "Associations"
    assert_text "All associations will be carried over and no additional associations will need to be populated."
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
