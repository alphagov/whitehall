require 'unit/whitehall/authority/authority_test_helper'

class DepartmentWriterTest < ActiveSupport::TestCase
  def department_writer
    OpenStruct.new(department_writer?: false, departmental_editor?: false)
  end

  include AuthorityTestHelper

  test 'can see an edition or document that is not access limited' do
    assert enforcer_for(department_writer, normal_edition).can?(:see)
  end

  test 'can create a new document' do
    assert enforcer_for(department_writer, Document).can?(:create)
  end

  test 'can create a new edition of a document that is not access limited' do
    assert enforcer_for(department_writer, normal_edition).can?(:create)
  end

  test 'can make changes to an edition that is not access limited' do
    assert enforcer_for(department_writer, normal_edition).can?(:update)
  end

  test 'can make a fact check request for a document' do
    assert enforcer_for(department_writer, normal_edition).can?(:request_fact_check)
  end

  test 'can view fact check requests on a document' do
    assert enforcer_for(department_writer, normal_edition).can?(:review_fact_check)
  end

  test 'cannot review a submitted edition' do
    refute enforcer_for(department_writer, submitted_edition).can?(:approve)
  end

  test 'cannot publish a submitted edition' do
    refute enforcer_for(department_writer, submitted_edition).can?(:publish)
  end

  test 'cannot reject a submitted edition' do
    refute enforcer_for(department_writer, submitted_edition).can?(:reject)
  end

  test 'cannot force publish a edition' do
    refute enforcer_for(department_writer, submitted_edition).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(department_writer, normal_edition).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(department_writer, normal_edition).can?(:review_editorial_remark)
  end

  test 'cannot clear the "not reviewed" flag on edition' do
    refute enforcer_for(department_writer, force_published_edition(department_writer)).can?(:approve)
  end

  test 'can limit access to an edition' do
    assert enforcer_for(department_writer, normal_edition).can?(:limit_access)
  end

  test 'can see an edition that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = department_writer
    user.stubs(:organisations).returns([org])
    edition = limited_edition([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an edition that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_writer
    user.stubs(:organisations).returns([org1])
    edition = limited_edition([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot unpublish an edition' do
    refute enforcer_for(department_writer, normal_edition).can?(:unpublish)
  end
end
