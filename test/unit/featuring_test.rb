require 'test_helper'

class FeaturingTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    featuring = build(:featuring)
    assert featuring.valid?
  end

  test 'should be invalid without an image' do
    featuring = build(:featuring, image: nil)
    refute featuring.valid?
  end
end
