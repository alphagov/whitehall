require "test_helper"

class UserOrderableClassTest < ActiveSupport::TestCase
  test "#reorder_without_callbacks! reorders the ordering of the collection using #update_column based on the params and column name passed in" do
    org1 = create(:ministerial_department, ministerial_ordering: 1)
    org2 = create(:ministerial_department, ministerial_ordering: 2)

    Organisation.stubs(:find).with(org1.id).returns(org1)
    Organisation.stubs(:find).with(org2.id).returns(org2)

    org2.expects(:update_column).with(:ministerial_ordering, "1").once
    org1.expects(:update_column).with(:ministerial_ordering, "2").once

    Organisation.reorder_without_callbacks!(
      {
        org2.id => "1",
        org1.id => "2",
      },
      :ministerial_ordering,
    )
  end
end
