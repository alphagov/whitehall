require "test_helper"

class Admin::RepublishingHelperTest < ActionView::TestCase
  setup do
    @first_row = republishing_index_bulk_republishing_rows.first
  end

  test "#republishing_index_bulk_republishing_rows capitalises the first letter of the bulk content type" do
    assert_equal @first_row.first[:text], "All documents"
  end

  test "#republishing_index_bulk_republishing_rows creates a link to the specific bulk republishing confirmation page" do
    expected_link = '<a id="all-documents" class="govuk-link" href="/government/admin/republishing/bulk/all-documents/confirm">Republish <span class="govuk-visually-hidden">all documents</span></a>'
    assert_equal @first_row[1][:text], expected_link
  end
end
