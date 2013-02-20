require 'test_helper'

class WorldwideOfficeTest < ActiveSupport::TestCase
  %w{contact worldwide_organisation}.each do |param|
    test "should not be valid without a #{param}" do
      refute build(:worldwide_office, param.to_sym => nil).valid?
    end
  end
end
