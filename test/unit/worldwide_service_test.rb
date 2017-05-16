require 'test_helper'

class WorldwideOfficeTest < ActiveSupport::TestCase
  %w{name service_type_id}.each do |param|
    test "should not be valid without a #{param}" do
      refute build(:worldwide_service, param.to_sym => nil).valid?
    end
  end

  test "should allow setting of service type" do
    worldwide_service = build(:worldwide_service, service_type: WorldwideServiceType::OtherServices)
    assert worldwide_service.valid?
  end
end
