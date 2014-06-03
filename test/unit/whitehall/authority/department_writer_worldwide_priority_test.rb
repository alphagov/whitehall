require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class DepartmentWriterWorldwidePriorityTest < ActiveSupport::TestCase
  def department_writer(id = 1)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, organisation: nil)
  end

  include AuthorityTestHelper

  test 'can create a new worldwide priority' do
    assert enforcer_for(department_writer, WorldwidePriority).can?(:create)
  end

  test 'can see an worldwide priority that is not access limited' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:see)
  end

  test 'can see an worldwide priority that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = department_writer
    user.stubs(:organisation).returns(org)
    edition = limited_worldwide_priority([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an worldwide priority that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    edition = limited_worldwide_priority([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to an worldwide priority they are not allowed to see' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    edition = limited_worldwide_priority([org2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::WorldEditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new worldwide priority of a document that is not access limited' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:create)
  end

  test 'can make changes to an worldwide priority that is not access limited' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:update)
  end

  test 'can delete an worldwide priority that is not access limited' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:delete)
  end

  test 'can make a fact check request for an worldwide priority' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:make_fact_check)
  end

  test 'can view fact check requests on an worldwide priority' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:review_fact_check)
  end

  test 'cannot publish an worldwide priority' do
    refute enforcer_for(department_writer, normal_worldwide_priority).can?(:publish)
  end

  test 'cannot reject an worldwide priority' do
    refute enforcer_for(department_writer, normal_worldwide_priority).can?(:reject)
  end

  test 'cannot force publish a worldwide priority' do
    refute enforcer_for(department_writer, normal_worldwide_priority).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:review_editorial_remark)
  end

  test 'cannot clear the "not reviewed" flag on worldwide priority' do
    refute enforcer_for(department_writer, normal_worldwide_priority).can?(:approve)
  end

  test 'can limit access to an worldwide priority' do
    assert enforcer_for(department_writer, normal_worldwide_priority).can?(:limit_access)
  end

  test 'cannot unpublish an worldwide priority' do
    refute enforcer_for(department_writer, normal_worldwide_priority).can?(:unpublish)
  end
end
