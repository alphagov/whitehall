require "test_helper"

class Admin::EditionRoutesHelperTest < ActionView::TestCase
  test "admin_edition_path take an edition instance and uses polymorphic routes to generate the correct path" do
    p = FactoryBot.create(:publication)
    assert_equal "/government/admin/publications/#{p.id}", admin_edition_path(p)
  end

  test "admin_edition_url takes an edition instance and uses polymorphic routes to generate the correct whitehall-admin url by default" do
    admin_host = "whitehall-admin.production.alphagov.co.uk"
    Whitehall.stubs(:admin_host).returns(admin_host)
    s = FactoryBot.create(:speech)
    assert_equal "http://#{admin_host}/government/admin/speeches/#{s.id}", admin_edition_url(s)
  end

  test "admin_edition_url takes an edition instance and uses polymorphic routes to generate the correct url for the specified hostname" do
    s = FactoryBot.create(:speech)
    assert_equal "http://www.gov.uk/government/admin/speeches/#{s.id}", admin_edition_url(s, host: "www.gov.uk")
  end

  test "edit_admin_edition_path take an edition instance and uses polymorphic routes to generate the correct path" do
    s = FactoryBot.create(:speech)
    assert_equal "/government/admin/speeches/#{s.id}/edit", edit_admin_edition_path(s)
  end
end
