require_relative "authority_test_helper"
require "ostruct"

class DepartmentWriterFatalityNoticeTest < ActiveSupport::TestCase
  def fatality_department_writer(id = 1)
    o = OpenStruct.new(id:, handles_fatalities?: true)
    OpenStruct.new(id:, gds_editor?: false, departmental_editor?: false, organisation: o)
  end

  def normal_department_writer(id = 1)
    o = OpenStruct.new(id:, handles_fatalities?: false)
    OpenStruct.new(id:, gds_editor?: false, departmental_editor?: false, organisation: o)
  end

  include AuthorityTestHelper

  test "can create a new fatality notice if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, FatalityNotice).can?(:create)
  end

  test "cannot create a new fatality notice if their organisation cannot handle fatalities" do
    assert_not enforcer_for(normal_department_writer, FatalityNotice).can?(:create)
  end

  test "cannot do anything to a fatality notice if their organisation cannot handle fatalities" do
    user = normal_department_writer(10)
    edition = normal_fatality_notice
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action)
    end
  end

  test "can see a fatality notice that is not access limited if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:see)
  end

  test "can see a fatality notice that is access limited if it is limited to their organisation if their organisation can handle fatalities" do
    user = fatality_department_writer
    edition = limited_fatality_notice([user.organisation])
    assert enforcer_for(user, edition).can?(:see)
  end

  test "cannot see a fatality notice that is access limited if it is limited an organisation they don't belong to if their organisation can handle fatalities" do
    user = fatality_department_writer(10)
    edition = limited_fatality_notice([OpenStruct.new(id: 100, handles_fatalities?: true)])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "cannot do anything to a fatality notice they are not allowed to see if their organisation can handle fatalities" do
    user = fatality_department_writer(10)
    edition = limited_fatality_notice([OpenStruct.new(id: 100, handles_fatalities?: true)])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action)
    end
  end

  test "can create a new edition of a fatality notice that is not access limited if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:create)
  end

  test "can make changes to a fatality notice that is not access limited if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:update)
  end

  test "can make a fact check request for a edition if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:make_fact_check)
  end

  test "can view fact check requests on a edition if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:review_fact_check)
  end

  test "cannot publish a fatality notice if their organisation can handle fatalities" do
    assert_not enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:publish)
  end

  test "cannot reject a fatality notice if their organisation can handle fatalities" do
    assert_not enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:reject)
  end

  test "cannot force publish a fatality notice if their organisation can handle fatalities" do
    assert_not enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:force_publish)
  end

  test "can make editorial remarks if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:make_editorial_remark)
  end

  test "can review editorial remarks if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:review_editorial_remark)
  end

  test 'cannot clear the "not reviewed" flag on a fatality notice if their organisation can handle fatalities' do
    assert_not enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:approve)
  end

  test "can limit access to a fatality notice if their organisation can handle fatalities" do
    assert enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:limit_access)
  end

  test "cannot unpublish a fatality notice if their organisation can handle fatalities" do
    assert_not enforcer_for(fatality_department_writer, normal_fatality_notice).can?(:unpublish)
  end
end
