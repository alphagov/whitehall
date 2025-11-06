require "test_helper"

class UriValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = UriValidator.new(attributes: [:url])
  end

  test "validates nil urls" do
    feature_link = validate(PromotionalFeatureLink.new(url: nil))
    assert feature_link.errors.empty?
  end

  test "validates http urls" do
    feature_link = validate(PromotionalFeatureLink.new(url: "http://example.com"))
    assert feature_link.errors.empty?
  end

  test "validates https urls" do
    feature_link = validate(PromotionalFeatureLink.new(url: "https://example.com"))
    assert feature_link.errors.empty?
  end

  test "non-http(s) URLs are not valid" do
    feature_link = validate(PromotionalFeatureLink.new(url: "ftp://example.com"))
    assert_equal ["is not a valid URI. Make sure it starts with http(s)"], feature_link.errors[:url]

    feature_link = validate(PromotionalFeatureLink.new(url: "gopher://example.com"))
    assert_equal ["is not a valid URI. Make sure it starts with http(s)"], feature_link.errors[:url]

    feature_link = validate(PromotionalFeatureLink.new(url: "mailto:name@example.com"))
    assert_equal ["is not a valid URI. Make sure it starts with http(s)"], feature_link.errors[:url]
  end

  test "invalid urls get an error if they aren't https/http and are poorly formatted" do
    feature_link = validate(PromotionalFeatureLink.new(url: "mailto://example.com"))
    assert_equal ["is not a valid URI."], feature_link.errors[:url]
  end

  test "invalid urls get an error if they include whitespace" do
    feature_link = validate(PromotionalFeatureLink.new(url: "https://example.come/guidance/inspire-index-polygons-spatial-data blah blah"))
    assert_equal ["is not a valid URI."], feature_link.errors[:url]
  end

  test "invalid urls get an error, without http" do
    feature_link = validate(PromotionalFeatureLink.new(url: "example.com"))
    assert_equal ["is not a valid URI. Make sure it starts with http(s)"], feature_link.errors[:url]
  end

  test "invalid urls get an error, with http" do
    feature_link = validate(PromotionalFeatureLink.new(url: "http ://example.com"))
    assert_equal ["is not a valid URI."], feature_link.errors[:url]
  end

  test "invalid urls get an error, with http without a space" do
    feature_link = validate(PromotionalFeatureLink.new(url: "http://abc</option%3E"))
    assert_equal ["is not a valid URI."], feature_link.errors[:url]
  end

  test "should be valid with 255 character alternative url" do
    alternative_url_255_character = "https://1HHGPav0JgJ6r1rJR34wO2Tksnimp6DjWIrJU02iQgcUK6H7he4aWZ5wrtNGOifEHoLO9afMMfNIZxoOTj6BkQE7NcBwY4fvYpCXwCFaBjnXkRqyl3LfFAIJc5GUXz64LGwQvHQHiOkFdP2fk43HkM2Dx6aHoHxdgRHRB7jVzGNLNwUBQtFdjlLv4CBHRTFMnHBtSsskEXhSGlv0TubV2uouqlUkoLSOwC3AJHa4XN1bcD23112.com"
    feature_link = validate(PromotionalFeatureLink.new(url: alternative_url_255_character))
    assert feature_link.errors.empty?
  end

  test "should error with more than 255 character alternative url" do
    alternative_url_256_character = "https://1HHGPav0JgJ6r1rJR34wO2Tksnimp6DjWIrJU02iQgcUK6H7he4aWZ5wrtNGOifEHoLO9afMMfNIZxoOTj6BkQE7NcBwY4fvYpCXwCFaBjnXkRqyl3LfFAIJc5GUXz64LGwQvHQHiOkFdP2fk43HkM2Dx6aHoHxdgRHRB7jVzGNLNwUBQtFdjlLv4CBHRTFMnHBtSsskEXhSGlv0TubV2uouqlUkoLSOwC3AJHa4XN1bcD231125.com"
    feature_link = validate(PromotionalFeatureLink.new(url: alternative_url_256_character))
    assert_includes feature_link.errors[:url], I18n.t("activerecord.errors.models.nation_inapplicability.attributes.alternative_url.too_long")
  end

private

  def validate(record)
    @validator.validate(record)
    record
  end
end
