require 'test_helper'

class PromotionalFeatureItemTest < ActiveSupport::TestCase

  test "invalid without a summary" do
    refute build(:promotional_feature_item, summary: nil).valid?
  end

  test "limits summary to a maximum of 500 characters" do
    assert build(:promotional_feature_item, summary: string_of_length(500)).valid?

    item = build(:promotional_feature_item, summary: string_of_length(501))
    refute item.valid?
    assert_equal ["is too long (maximum is 500 characters)"], item.errors[:summary]
  end

  test "validates the title url is valid if supplied" do
    item = build(:promotional_feature_item, title_url: 'ftp://invalid.com')
    refute item.valid?
    assert_equal ["is not valid. Make sure it starts with http(s)"], item.errors[:title_url]
  end

  test "accepts nested attributes for links" do
    item = create(:promotional_feature_item, links_attributes: [{url: 'http://example.com', text: 'Example link'}])
    assert_equal 1, item.links.count
    assert_equal 'http://example.com', item.links.first.url
    assert_equal 'Example link', item.links.first.text
  end

  private

  def string_of_length(length)
    'X' * length
  end
end
