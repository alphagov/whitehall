require 'test_helper'

class UrlValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = UrlValidator.new(attributes: [:url])
  end

  test "validates http urls" do
    feature_link = validate(PromotionalFeatureLink.new(url: 'http://example.com'))
    assert feature_link.errors.empty?
  end

  test "validates https urls" do
    feature_link = validate(PromotionalFeatureLink.new(url: 'https://example.com'))
    assert feature_link.errors.empty?
  end

  test "non-http(s) URLs are not valid" do
    feature_link = validate(PromotionalFeatureLink.new(url: 'ftp://example.com'))
    assert_equal ['is not valid. Make sure it starts with http(s)'], feature_link.errors[:url]

    feature_link = validate(PromotionalFeatureLink.new(url: 'gopher://example.com'))
    assert_equal ['is not valid. Make sure it starts with http(s)'], feature_link.errors[:url]

    feature_link = validate(PromotionalFeatureLink.new(url: 'mailto://example.com'))
    assert_equal ['is not valid. Make sure it starts with http(s)'], feature_link.errors[:url]
  end

  test "invalid urls get an error" do
    feature_link = validate(PromotionalFeatureLink.new(url: 'example.com'))
    assert_equal ['is not valid. Make sure it starts with http(s)'], feature_link.errors[:url]
  end

  private

  def validate(record)
    @validator.validate(record)
    record
  end
end
