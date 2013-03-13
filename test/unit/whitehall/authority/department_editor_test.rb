require 'unit/whitehall/authority/authority_test_helper'

class DepartmentEditorTest < ActiveSupport::TestCase
  def department_editor
    OpenStruct.new(department_editor?: false, departmental_editor?: true)
  end

  include AuthorityTestHelper

  test 'can see an edition or document that is not access limited' do
    assert enforcer_for(department_editor, normal_edition).can?(:see)
  end

  test 'can create a new document' do
    assert enforcer_for(department_editor, Document).can?(:create)
  end

  test 'can create a new edition of a document that is not access limited' do
    assert enforcer_for(department_editor, normal_edition).can?(:create)
  end

  test 'can make changes to an edition that is not access limited' do
    assert enforcer_for(department_editor, normal_edition).can?(:update)
  end

  test 'can make a fact check request for a document' do
    assert enforcer_for(department_editor, normal_edition).can?(:request_fact_check)
  end

  test 'can view fact check requests on a document' do
    assert enforcer_for(department_editor, normal_edition).can?(:review_fact_check)
  end

  test 'can review a submitted edition' do
    assert enforcer_for(department_editor, submitted_edition).can?(:approve)
  end

  test 'can publish a submitted edition' do
    assert enforcer_for(department_editor, submitted_edition).can?(:publish)
  end

  test 'can reject a submitted edition' do
    assert enforcer_for(department_editor, submitted_edition).can?(:reject)
  end

  test 'can force publish a edition' do
    assert enforcer_for(department_editor, submitted_edition).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(department_editor, normal_edition).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(department_editor, normal_edition).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on editions they didn\'t force publish' do
    assert enforcer_for(department_editor, force_published_edition(department_editor)).can?(:review)
  end

  test 'cannot clear the "not reviewed" flag on editions they did force publish' do
    user = department_editor
    refute enforcer_for(user, force_published_edition(user)).can?(:approve)
  end

  test 'can limit access to an edition' do
    assert enforcer_for(department_editor, normal_edition).can?(:limit_access)
  end

  test 'can see an edition that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = department_editor
    user.stubs(:organisations).returns([org])
    edition = limited_edition([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an edition that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = department_editor
    user.stubs(:organisations).returns([org1])
    edition = limited_edition([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot unpublish an edition' do
    refute enforcer_for(department_editor, normal_edition).can?(:unpublish)
  end
end
