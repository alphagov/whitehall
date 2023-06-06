require "test_helper"

class Admin::CancelRoutesHelperTest < ActionView::TestCase
  test "admin_cancel_path take a new edition instance and generates the correct path" do
    edition = build(:edition)
    assert_equal "/government/admin/editions", admin_cancel_path(edition)
  end

  test "admin_cancel_path take a new corporate_information_page instance and generates the correct path" do
    organisation = build_stubbed(:organisation, slug: "organisation-ID")
    page = build(:corporate_information_page, organisation:)
    assert_equal "/government/admin/organisations/#{organisation.slug}/corporate_information_pages", admin_cancel_path(page)
  end

  test "admin_cancel_path take an edition instance and generates the correct path" do
    edition = build_stubbed(:edition)
    assert_equal "/government/admin/generic-editions/#{edition.id}", admin_cancel_path(edition)
  end

  test "admin_cancel_path take an corporate_information_page instance and generates the correct path" do
    organisation = build_stubbed(:organisation, slug: "organisation-ID")
    page = build_stubbed(:corporate_information_page, organisation:)
    assert_equal "/government/admin/organisations/#{organisation.slug}/corporate_information_pages/#{page.id}", admin_cancel_path(page)
  end
end
