require 'test_helper'

class PromotionalFeatureLinkTest < ActiveSupport::TestCase
  test 'is not valid without a url, text or promotional_feature_item' do
    %w(url text promotional_feature_item).each do |attribute|
      link = build(:promotional_feature_link, attribute => nil)
      refute link.valid?
      assert_includes link.errors[attribute], "can't be blank"
    end
  end

  test 'must have a valid URL' do
    link = build(:promotional_feature_link, url: 'example.com')
    refute link.valid?
    assert_equal ['is not valid. Make sure it starts with http(s)'], link.errors[:url]
  end
end
