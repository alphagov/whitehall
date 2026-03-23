require "test_helper"

class Edition::UrlsTest < ActiveSupport::TestCase
  def edition
    @edition ||= create(:published_publication, title: "Price of steel")
  end

  test "base_path is the path on GOV.UK without a locale or query parameters" do
    assert_equal "/government/publications/price-of-steel",
                 edition.base_path
  end

  test "public_path is the path to the document on GOV.UK" do
    assert_equal "/government/publications/price-of-steel",
                 edition.public_path
  end

  test "public_path accepts locale parameter" do
    assert_equal "/government/publications/price-of-steel.fr",
                 edition.public_path(locale: "fr")
  end

  test "public_path defaults to using the primary locale" do
    edition.primary_locale = "fr"
    assert_equal "/government/publications/price-of-steel.fr",
                 edition.public_path
  end

  test "public_url is a full URL to the document on GOV.UK" do
    assert_equal "https://www.test.gov.uk/government/publications/price-of-steel",
                 edition.public_url
  end

  test "public_url with `draft: true` links to the draft stack" do
    assert_equal "https://draft-origin.test.gov.uk/government/publications/price-of-steel",
                 edition.public_url(draft: true)
  end

  test "public_url defaults to using the primary_locale" do
    edition.primary_locale = "fr"
    assert_equal "https://www.test.gov.uk/government/publications/price-of-steel.fr",
                 edition.public_url
  end
end
