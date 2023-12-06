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

  test "#reorder! reorders the collection using #update! based on the params passed in" do
    take_part_page1 = create(:take_part_page, ordering: 1)
    take_part_page2 = create(:take_part_page, ordering: 2)

    TakePartPage.stubs(:find).with(take_part_page1.id).returns(take_part_page1)
    TakePartPage.stubs(:find).with(take_part_page2.id).returns(take_part_page2)

    take_part_page2.expects(:update!).with(ordering: "1").once
    take_part_page1.expects(:update!).with(ordering: "2").once

    TakePartPage.reorder!(
      {
        take_part_page2.id => "1",
        take_part_page1.id => "2",
      },
      :ordering,
    )
  end
end
