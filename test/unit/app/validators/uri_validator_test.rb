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

  test "validates internal GOV.UK URLs" do
    feature_link = validate(PromotionalFeatureLink.new(url: "/foo"))
    assert feature_link.errors.empty?
  end

  # See https://github.com/alphagov/publishing-api/blob/537a4d62960e6fc7ea7ffa4e245dba006172b5df/app/validators/routes_and_redirects_validator.rb#L201-L202
  test "absolute GOV.UK URLs are not valid (they're rejected by Publishing API)" do
    feature_link = validate(PromotionalFeatureLink.new(url: "https://www.gov.uk/foo"))
    assert_equal ["is not valid. A redirect to a page on GOV.UK should not be specified with a full url (e.g. use '/example' rather than 'https://www.gov.uk/example')"], feature_link.errors[:url]
  end

  test "non-http(s) URLs are not valid" do
    feature_link = validate(PromotionalFeatureLink.new(url: "ftp://example.com"))
    assert_equal ["is not valid. Make sure it starts with http(s)"], feature_link.errors[:url]

    feature_link = validate(PromotionalFeatureLink.new(url: "gopher://example.com"))
    assert_equal ["is not valid. Make sure it starts with http(s)"], feature_link.errors[:url]

    feature_link = validate(PromotionalFeatureLink.new(url: "mailto:name@example.com"))
    assert_equal ["is not valid. Make sure it starts with http(s)"], feature_link.errors[:url]
  end

  test "invalid urls get an error if they aren't https/http and are poorly formatted" do
    feature_link = validate(PromotionalFeatureLink.new(url: "mailto://example.com"))
    assert_equal ["is not valid."], feature_link.errors[:url]
  end

  test "invalid urls get an error if they include whitespace" do
    feature_link = validate(PromotionalFeatureLink.new(url: "https://example.come/guidance/inspire-index-polygons-spatial-data blah blah"))
    assert_equal ["is not valid."], feature_link.errors[:url]
  end

  test "invalid urls get an error, without http" do
    feature_link = validate(PromotionalFeatureLink.new(url: "example.com"))
    assert_equal ["is not valid. Make sure it starts with http(s)"], feature_link.errors[:url]
  end

  test "invalid urls get an error, with http" do
    feature_link = validate(PromotionalFeatureLink.new(url: "http ://example.com"))
    assert_equal ["is not valid."], feature_link.errors[:url]
  end

  test "invalid urls get an error, with http without a space" do
    feature_link = validate(PromotionalFeatureLink.new(url: "http://abc</option%3E"))
    assert_equal ["is not valid."], feature_link.errors[:url]
  end

private

  def validate(record)
    @validator.validate(record)
    record
  end
end
