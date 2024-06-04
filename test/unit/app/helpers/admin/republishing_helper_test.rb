require "test_helper"

class Admin::RepublishingHelperTest < ActionView::TestCase
  test "#republishing_index_bulk_republishing_rows capitalises the first letter of the bulk content type" do
    first_bulk_content_type = republishing_index_bulk_republishing_rows.first.first[:text]

    assert_equal first_bulk_content_type, "All documents"
  end

  test "#republishing_index_bulk_republishing_rows creates a link to the specific bulk republishing confirmation page" do
    first_link = republishing_index_bulk_republishing_rows.first[1][:text]
    expected_link = '<a id="all-documents" class="govuk-link" href="/government/admin/republishing/bulk/all-documents/confirm">Republish <span class="govuk-visually-hidden">all documents</span></a>'

    assert_equal first_link, expected_link
  end
end
