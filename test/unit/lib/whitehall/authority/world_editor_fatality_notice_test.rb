require_relative "authority_test_helper"
require "ostruct"

class WorldEditorFatalityNoticeTest < ActiveSupport::TestCase
  def fatality_world_editor(world_locations, id = 1)
    o = OpenStruct.new(id:, handles_fatalities?: true)
    OpenStruct.new(
      id:,
      gds_editor?: false,
      departmental_editor?: false,
      world_editor?: true,
      organisation: o,
      world_locations: world_locations || [],
    )
  end

  def normal_world_editor(world_locations, id = 1)
    o = OpenStruct.new(id:, handles_fatalities?: false)
    OpenStruct.new(
      id:,
      gds_editor?: false,
      departmental_editor?: false,
      world_editor?: true,
      organisation: o,
      world_locations: world_locations || [],
    )
  end

  include AuthorityTestHelper

  test "cannot create a new fatality notice about their location if their organisation cannot handle fatalities" do
    assert_not enforcer_for(normal_world_editor(["hat land"]), FatalityNotice).can?(:create)
  end

  test "cannot create a new fatality notice about their location even if their organisation can handle fatalities" do
    assert_not enforcer_for(fatality_world_editor(["hat land"]), FatalityNotice).can?(:create)
  end

  test "cannot see a fatality notice about their location if their organisation cannot handle fatalities" do
    user = normal_world_editor(["hat land", "tie land"])
    edition = with_locations(normal_fatality_notice, ["shirt land", "hat land"])
    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "cannot see a fatality notice about their location even if their organisation can handle fatalities" do
    user = fatality_world_editor(["hat land", "tie land"])
    edition = with_locations(normal_fatality_notice, ["shirt land", "hat land"])
    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "cannot do anything to a fatality notice about their location if their organisation cannot handle fatalities" do
    user = normal_world_editor(["hat land", "tie land"])
    edition = with_locations(normal_fatality_notice, ["shirt land", "hat land"])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action)
    end
  end

  test "cannot do anything to a fatality notice about their location even if their organisation can handle fatalities" do
    user = fatality_world_editor(["hat land", "tie land"])
    edition = with_locations(normal_fatality_notice, ["shirt land", "hat land"])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action)
    end
  end
end
