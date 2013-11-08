require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class GDSEditorTest < ActiveSupport::TestCase
  def gds_editor(id = 1)
    OpenStruct.new(id: id, gds_editor?: true, organisation: nil,
                   can_force_publish_anything?: false)
  end

  include AuthorityTestHelper

  test 'can create a new document' do
    assert enforcer_for(gds_editor, Document).can?(:create)
  end

  test 'can create a new Edition' do
    assert enforcer_for(gds_editor, Edition).can?(:create)
  end

  test 'can see an edition that is not access limited' do
    assert enforcer_for(gds_editor, normal_edition).can?(:see)
  end

  test 'can see an edition that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = gds_editor
    user.stubs(:organisation).returns(org)
    edition = limited_edition([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an edition that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_edition([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to an edition they are not allowed to see' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_edition([org2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new edition of a document that is not access limited' do
    assert enforcer_for(gds_editor, normal_edition).can?(:create)
  end

  test 'can make changes to an edition that is not access limited' do
    assert enforcer_for(gds_editor, normal_edition).can?(:update)
  end

  test 'can delete an edition that is not access limited' do
    assert enforcer_for(gds_editor, normal_edition).can?(:delete)
  end

  test 'can make a fact check request for an edition' do
    assert enforcer_for(gds_editor, normal_edition).can?(:make_fact_check)
  end

  test 'can view fact check requests on an edition' do
    assert enforcer_for(gds_editor, normal_edition).can?(:review_fact_check)
  end

  test 'can publish an edition' do
    assert enforcer_for(gds_editor, normal_edition).can?(:publish)
  end

  test 'cannot publish an edition we created' do
    me = gds_editor
    refute enforcer_for(me, normal_edition(me)).can?(:publish)
  end

  test 'cannot publish a scheduled edition' do
    refute enforcer_for(gds_editor, scheduled_edition).can?(:publish)
  end

  test 'can reject an edition' do
    assert enforcer_for(gds_editor, normal_edition).can?(:reject)
  end

  test 'can force publish a edition' do
    assert enforcer_for(gds_editor, normal_edition).can?(:force_publish)
  end

  test 'can force publish a edition we created' do
    me = gds_editor
    assert enforcer_for(me, normal_edition(me)).can?(:force_publish)
  end

  test 'can force publish a limited access edition outside their org if they can_force_publish_anything?' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    user.stubs(:can_force_publish_anything?).returns(true)
    edition = limited_edition([org2])

    assert enforcer_for(user, edition).can?(:force_publish)
  end

  test 'cannot force publish a scheduled edition' do
    refute enforcer_for(gds_editor, scheduled_edition).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(gds_editor, normal_edition).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(gds_editor, normal_edition).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on editions they didn\'t force publish' do
    assert enforcer_for(gds_editor(10), force_published_edition(gds_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on editions they did force publish' do
    me = gds_editor
    refute enforcer_for(me, force_published_edition(me)).can?(:approve)
  end

  test 'can clear the "not reviewed" flag on editions they did not force schedule' do
    assert enforcer_for(gds_editor(10), force_scheduled_edition(gds_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on editions they force scheduled' do
    user = gds_editor
    refute enforcer_for(user, force_scheduled_edition(user)).can?(:approve)
  end

  test 'can limit access to an edition' do
    assert enforcer_for(gds_editor, normal_edition).can?(:limit_access)
  end

  test 'cannot unpublish an edition' do
    refute enforcer_for(gds_editor, normal_edition).can?(:unpublish)
  end

  test 'can reorder cabinet ministers' do
    assert enforcer_for(gds_editor, MinisterialRole).can?(:reorder_cabinet_ministers)
  end

  test 'can administer the get_involved_section' do
    assert enforcer_for(gds_editor, :get_involved_section).can?(:administer)
  end
end
