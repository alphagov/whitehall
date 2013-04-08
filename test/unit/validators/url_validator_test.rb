require 'test_helper'

class UrlValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = UrlValidator.new(attributes: [:url])
  end

  test "validates http urls" do
    feature_link = PromotionalFeatureLink.new(url: 'http://example.com')
    @validator.validate(feature_link)
    assert feature_link.errors.empty?
  end

  test "validates https urls" do
    feature_link = PromotionalFeatureLink.new(url: 'https://example.com')
    @validator.validate(feature_link)
    assert feature_link.errors.empty?
  end

  test "invalid urls get an error" do
    feature_link = PromotionalFeatureLink.new(url: 'example.com')
    @validator.validate(feature_link)
    assert_equal ['is not a valid. Make sure it starts with http(s)'], feature_link.errors[:url]
  end
end
