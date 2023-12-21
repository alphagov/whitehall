require "test_helper"

class Admin::CancelRoutesHelperTest < ActionView::TestCase
  test "admin_cancel_path take a new edition instance and generates the correct path" do
    edition = build(:edition)
    assert_equal "/government/admin/editions", admin_cancel_path(edition)
  end

  test "admin_cancel_path take an edition instance and generates the correct path" do
    edition = build_stubbed(:edition)
    assert_equal "/government/admin/generic-editions/#{edition.id}", admin_cancel_path(edition)
  end
end
