require "test_helper"

class OrganisationMainstreamLinkTest < ActiveSupport::TestCase
  test "should not be valid without a slug" do
    link = build(:organisation_mainstream_link, slug: nil)
    refute link.valid?
  end

  test "should not be valid without a title" do
    link = build(:organisation_mainstream_link, title: nil)
    refute link.valid?
  end

  test "#public_url should prepend the public host if a slug is given" do
    link = build(:organisation_mainstream_link, slug: "/mainstream/gov")
    Whitehall.stubs(:public_host_for).with("admin-host").returns("public-host")
    assert_equal "http://public-host/mainstream/gov", link.public_url("admin-host")
  end

  test "#public_url should return the slug if it starts with a protocol" do
    link = build(:organisation_mainstream_link, slug: "https://some-other-host/mainstream/gov")
    assert_equal "https://some-other-host/mainstream/gov", link.public_url("admin-host")
  end

  test "#public_url should add a slash where a leading one is missing from the slug" do
    link = build(:organisation_mainstream_link, slug: "mainstream/gov")
    Whitehall.stubs(:public_host_for).with("admin-host").returns("public-host")
    assert_equal "http://public-host/mainstream/gov", link.public_url("admin-host")
  end
end
