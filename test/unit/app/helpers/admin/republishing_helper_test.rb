require "test_helper"

class Admin::RepublishingHelperTest < ActionView::TestCase
  test "#republishable_content_types returns a sorted list combining valid document types and other publishable content types" do
    Rails.application.eager_load!

    # Ignore "abstract" Edition descendants
    unexpected_content_types = %w[Announcement GenericEdition Publicationesque SearchableEdition]

    expected_content_types = (
      Edition.descendants.map(&:to_s) + non_editionable_content_types - unexpected_content_types
    ).reject { _1.include?("Test::") }.sort

    assert_equal expected_content_types, republishable_content_types
  end

  test "#non_editionable_content_types returns a list of non-editionable content types" do
    Rails.application.eager_load!
    expected_non_editionable_models = ApplicationRecord.subclasses
      .select { |subclass| subclass.included_modules.include? PublishesToPublishingApi }
      .map(&:to_s)
      .sort

    assert_equal expected_non_editionable_models, non_editionable_content_types.sort
  end

  test "#republishing_index_bulk_republishing_rows capitalises the first letter of the bulk content type" do
    first_bulk_content_type = republishing_index_bulk_republishing_rows.first.first[:text]

    assert_equal first_bulk_content_type, "All documents"
  end

  test "#republishing_index_bulk_republishing_rows creates a link to the confirmation page for content types that don't require extra input" do
    all_documents_link = republishing_index_bulk_republishing_rows.flatten.find { |column|
      column[:text].include?('Republish <span class="govuk-visually-hidden">all documents</span>')
    }[:text]

    expected_link = '<a id="all-documents" class="govuk-link" href="/government/admin/republishing/bulk/all-documents/confirm">Republish <span class="govuk-visually-hidden">all documents</span></a>'

    assert_equal expected_link, all_documents_link
  end

  test "#republishing_index_bulk_republishing_rows creates a link to the new page for content types that require extra input" do
    all_by_type_link = republishing_index_bulk_republishing_rows.flatten.find { |column|
      column[:text].include?('Republish <span class="govuk-visually-hidden">all by type</span>')
    }[:text]

    expected_link = '<a id="all-by-type" class="govuk-link" href="/government/admin/republishing/bulk/by-type/new">Republish <span class="govuk-visually-hidden">all by type</span></a>'

    assert_equal expected_link, all_by_type_link
  end

  test "#republishable_content_types_select_options creates select options from republishable_content_types" do
    options = republishable_content_types_select_options

    assert_includes options, {
      text: "CallForEvidence",
      value: "call-for-evidence",
    }

    assert_includes options, {
      text: "Contact",
      value: "contact",
    }
  end

  [
    { condition: "an empty string", input: "", expected_output: [] },
    { condition: "commas, space, and new lines with no IDs", input: "  \r ,  \r\n  ", expected_output: [] },
    { condition: "single IDs", input: "abc-123", expected_output: %w[abc-123] },
    { condition: "comma-separated IDs", input: "abc-123,def-456,ghi-789", expected_output: %w[abc-123 def-456 ghi-789] },
    { condition: "space-separated IDs", input: "abc-123 def-456  ghi-789", expected_output: %w[abc-123 def-456 ghi-789] },
    { condition: "new-line-separated IDs", input: "abc-123\ndef-456\n\rghi-789", expected_output: %w[abc-123 def-456 ghi-789] },
    { condition: "a mixture of comma-, space-, and new-line-separated IDs", input: "abc-123,def-456\n\rghi-789, jkl-012  \r  mno-345  , \n\r  , pqr-678", expected_output: %w[abc-123 def-456 ghi-789 jkl-012 mno-345 pqr-678] },
    { condition: "IDs with leading and trailing commas, space, and new lines", input: "\r\n , abc-123, def-456, ghi-789 \r, ", expected_output: %w[abc-123 def-456 ghi-789] },
  ].each do |test_config|
    test "#content_ids_string_to_array handles #{test_config[:condition]}" do
      assert_equal test_config[:expected_output], content_ids_string_to_array(test_config[:input])
    end
  end

  [
    { condition: "one ID", input: %w[abc-123], expected_output: "'abc-123'" },
    { condition: "two IDs", input: %w[abc-123 def-456], expected_output: "'abc-123' and 'def-456'" },
    { condition: "three or more IDs", input: %w[abc-123 def-456 ghi-789], expected_output: "'abc-123', 'def-456', and 'ghi-789'" },
  ].each do |test_config|
    test "#content_ids_array_to_string handles #{test_config[:condition]}" do
      assert_equal test_config[:expected_output], content_ids_array_to_string(test_config[:input])
    end
  end

  test "#content_ids_array_to_string throws an error if no IDs are provided" do
    assert_raises(StandardError, match: "No IDs provided") { content_ids_array_to_string([]) }
  end

  test "#confirm_documents_by_content_ids_edition_rows returns rows containing the title/link, state, and content ID for given documents' republishable editions" do
    document_a = create(:document, content_id: "abc-123")
    document_b = create(:document, content_id: "def-456")

    edition_with_url_1 = create(:published_edition, title: "I belong to the first document")
    edition_with_url_2 = create(:published_edition, title: "I belong to the second document")
    edition_without_url = create(:draft_edition, title: "I belong to the first document and I'm new and cool")

    document_a.stubs(:republishable_editions).returns([edition_with_url_1, edition_without_url])
    document_b.stubs(:republishable_editions).returns([edition_with_url_2])

    edition_with_url_1.stubs(:public_url).returns("https://gov.uk/url-1")
    edition_with_url_2.stubs(:public_url).returns("https://gov.uk/url-2")
    edition_without_url.stubs(:public_url).returns(nil)

    expected_rows = [
      [
        { text: '<a class="govuk-link" href="https://gov.uk/url-1">I belong to the first document</a>' },
        { text: "Published" },
        { text: "abc-123" },
      ],
      [
        { text: "I belong to the first document and I'm new and cool" },
        { text: "Draft" },
        { text: "abc-123" },
      ],
      [
        { text: '<a class="govuk-link" href="https://gov.uk/url-2">I belong to the second document</a>' },
        { text: "Published" },
        { text: "def-456" },
      ],
    ]

    assert_equal expected_rows, confirm_documents_by_content_ids_edition_rows([document_a, document_b])
  end
end
