require 'test_helper'

class WorldwideOfficeWorldwideServiceTest < ActiveSupport::TestCase
  %w{worldwide_office worldwide_service}.each do |param|
    test "should not be valid without a #{param}" do
      refute build(:worldwide_office_worldwide_service, param.to_sym => nil).valid?
    end
  end
end
