require 'test_helper'

class FeaturingTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    featuring = build(:featuring)
    assert featuring.valid?
  end
end
