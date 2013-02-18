# encoding: UTF-8
require "test_helper"

module Whitehall
  class WhipOrganisationTest < ActiveSupport::TestCase

    test "whip_org_for_role returns WhipsHouseOfCommons matching roles" do
      role1 = create(:ministerial_role, name: "Chief Whip and Parliamentary Secretary to the Treasury")
      role2 = create(:ministerial_role, name: "Deputy Chief Whip, Comptroller of HM Household")
      role3 = create(:ministerial_role, name: "Deputy Chief Whip, Treasurer of HM Household")
      role4 = create(:ministerial_role, name: "Government Whip, Vice Chamberlain of HM Household")
      assert_equal [Whitehall::WhipOrganisation.find_by_id(1)], Whitehall::WhipOrganisation.whip_org_for_role(role1)
      assert_equal [Whitehall::WhipOrganisation.find_by_id(1)], Whitehall::WhipOrganisation.whip_org_for_role(role2)
      assert_equal [Whitehall::WhipOrganisation.find_by_id(1)], Whitehall::WhipOrganisation.whip_org_for_role(role3)
      assert_equal [Whitehall::WhipOrganisation.find_by_id(1)], Whitehall::WhipOrganisation.whip_org_for_role(role4)
    end
    test "whip_org_for_role returns WhipsHouseofLords matching roles" do
      role1 = create(:ministerial_role, name: "Government Deputy Chief Whip and Captain of the Queen's Bodyguard of the Yeomen of the Guard")
      role2 = create(:ministerial_role, name: "Lords Chief Whip and Captain of the Honourable Corps of Gentlemen at Arms")
      assert_equal [Whitehall::WhipOrganisation.find_by_id(2)], Whitehall::WhipOrganisation.whip_org_for_role(role1)
      assert_equal [Whitehall::WhipOrganisation.find_by_id(2)], Whitehall::WhipOrganisation.whip_org_for_role(role2)
    end
    test "whip_org_for_role returns JuniorLordsoftheTreasury matching roles" do
      role = create(:ministerial_role, name: "Government Whip, Lord Commissioner of HM Treasury")
      assert_equal [Whitehall::WhipOrganisation.find_by_id(3)], Whitehall::WhipOrganisation.whip_org_for_role(role)
    end
    test "whip_org_for_role returns AssistantWhips matching roles" do
      role = create(:ministerial_role, name: "Assistant Whip")
      assert_equal [Whitehall::WhipOrganisation.find_by_id(4)], Whitehall::WhipOrganisation.whip_org_for_role(role)
    end
    test "whip_org_for_role returns BaronessAndLordsInWaiting matching roles" do
      role1 = create(:ministerial_role, name: "Government Whip, Baroness in Waiting")
      role2 = create(:ministerial_role, name: "Government Whip, Lord in Waiting")
      assert_equal [Whitehall::WhipOrganisation.find_by_id(5)], Whitehall::WhipOrganisation.whip_org_for_role(role1)
      assert_equal [Whitehall::WhipOrganisation.find_by_id(5)], Whitehall::WhipOrganisation.whip_org_for_role(role2)
    end

    test "role_is_a_whip? returns true if a given role is a whip role" do
      role = create(:ministerial_role, name: "Assistant Whip")
      assert_equal true, Whitehall::WhipOrganisation.role_is_a_whip?(role)
    end

    test "role_is_a_whip? returns false if a given role is not a whip role" do
      role = create(:ministerial_role, name: "Prime Minister")
      assert_equal false, Whitehall::WhipOrganisation.role_is_a_whip?(role)
    end
  end
end
