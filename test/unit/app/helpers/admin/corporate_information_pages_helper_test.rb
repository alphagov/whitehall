require "test_helper"

class Admin::CorporateInformationPagesHelperTest < ActionView::TestCase
  test "#index_table_title_row returns the title for an edition with a primary locale of :en" do
    edition = build(:edition, title: "title")
    assert_equal "title", index_table_title_row(edition)
  end

  test "#index_table_title_row returns the title and locale for an edition with a non-english primary locale" do
    edition = build(:edition, title: "title", primary_locale: :fr)
    assert_equal "title (fr)", index_table_title_row(edition)
  end
end
