require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class DepartmentWriterWorldwidePriorityTest < ActiveSupport::TestCase
  def department_writer(id = 1)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, organisation: nil)
  end

  include AuthorityTestHelper

  test 'cannot create a new WorldwidePriority' do
    refute enforcer_for(department_writer, WorldwidePriority).can?(:create)
  end

  test 'cannot see a worldwide priority that is not access limited' do
    refute enforcer_for(department_writer, normal_worldwide_priority).can?(:see)
  end

  test 'cannot see an worldwide priority that is access limited even if it is limited to their organisation' do
    org = 'organisation'
    user = department_writer
    user.stubs(:organisation).returns(org)
    edition = limited_worldwide_priority([org])
    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an worldwide priority that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    edition = limited_worldwide_priority([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to a worldwide prioritys' do
    user = department_writer
    edition = normal_worldwide_priority
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end
end
