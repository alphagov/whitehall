require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class DepartmentWriterTest < ActiveSupport::TestCase
  def department_writer(id = 1)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, organisation: nil,
                   can_force_publish_anything?: false)
  end

  include AuthorityTestHelper

  test 'can create a new document' do
    assert enforcer_for(department_writer, Document).can?(:create)
  end

  test 'can create a new edition' do
    assert enforcer_for(department_writer, Edition).can?(:create)
  end

  test 'can see an edition that is not access limited' do
    assert enforcer_for(department_writer, normal_edition).can?(:see)
  end

  test 'can see an edition that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = department_writer
    user.stubs(:organisation).returns(org)
    edition = limited_edition([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an edition that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    edition = limited_edition([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to an edition they are not allowed to see' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    edition = limited_edition([org2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new edition of a document that is not access limited' do
    assert enforcer_for(department_writer, normal_edition).can?(:create)
  end

  test 'can make changes to an edition that is not access limited' do
    assert enforcer_for(department_writer, normal_edition).can?(:update)
  end

  test 'can delete an edition that is not access limited' do
    assert enforcer_for(department_writer, normal_edition).can?(:delete)
  end

  test 'can make a fact check request for an edition' do
    assert enforcer_for(department_writer, normal_edition).can?(:make_fact_check)
  end

  test 'can view fact check requests on an edition' do
    assert enforcer_for(department_writer, normal_edition).can?(:review_fact_check)
  end

  test 'cannot publish an edition' do
    refute enforcer_for(department_writer, normal_edition).can?(:publish)
  end

  test 'cannot publish a scheduled edition' do
    refute enforcer_for(department_writer, scheduled_edition).can?(:publish)
  end

  test 'cannot reject an edition' do
    refute enforcer_for(department_writer, normal_edition).can?(:reject)
  end

  test 'cannot force publish a edition' do
    refute enforcer_for(department_writer, normal_edition).can?(:force_publish)
  end

  test 'cannot force publish a scheduled edition' do
    refute enforcer_for(department_writer, scheduled_edition).can?(:force_publish)
  end

  test 'can force publish an edition if they can_force_publish_anything?' do
    user = department_writer
    user.stubs(:can_force_publish_anything?).returns(true)

    assert enforcer_for(user, normal_edition).can?(:force_publish)
  end

  test 'can force publish a limited access edition outside their org if they can_force_publish_anything?' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisation).returns(org1)
    user.stubs(:can_force_publish_anything?).returns(true)
    edition = limited_edition([org2])

    assert enforcer_for(user, edition).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(department_writer, normal_edition).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(department_writer, normal_edition).can?(:review_editorial_remark)
  end

  test 'cannot clear the "not reviewed" flag on edition' do
    refute enforcer_for(department_writer, normal_edition).can?(:approve)
  end

  test 'can limit access to an edition' do
    assert enforcer_for(department_writer, normal_edition).can?(:limit_access)
  end

  test 'cannot unpublish an edition' do
    refute enforcer_for(department_writer, normal_edition).can?(:unpublish)
  end

  test 'cannot administer the get_involved_section' do
    refute enforcer_for(department_writer, :get_involved_section).can?(:administer)
  end
end
