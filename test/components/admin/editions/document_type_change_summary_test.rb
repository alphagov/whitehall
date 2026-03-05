require "test_helper"

class Admin::Editions::DocumentTypeChangeSummaryTest < ViewComponent::TestCase
  def build_type(label:, properties: {})
    OpenStruct.new(
      label: label,
      properties: properties,
    )
  end

  test "renders summary lists for lost and new fields and associations" do
    old_type = build_type(
      label: "Old type",
      properties: {
        "body" => { "title" => "Body" },
        "image" => { "title" => "Custom lead image" },
      },
    )

    new_type = build_type(
      label: "New type",
      properties: {
        "summary" => { "title" => "Summary" },
        "body" => { "title" => "Body" },
      },
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

    # Lost field (image)
    assert_text "Custom lead image"
    assert_text "Will be deleted. A ‘New type’ does not have a ‘Custom lead image’ field."

    # New field (summary)
    assert_text "Summary"
    assert_text "Will need to be added. A ‘New type’ has a ‘Summary’ field. This field will be blank after the change."
  end

  test "renders fallback messages when there are no changes" do
    type = build_type(
      label: "Same type",
      properties: {
        "body" => { "title" => "Body" },
      },
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
  end

  test "handles missing properties gracefully" do
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
  end
end
