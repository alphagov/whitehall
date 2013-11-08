require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class GDSEditorFatalityNoticeTest < ActiveSupport::TestCase
  def gds_editor(id = 1)
    OpenStruct.new(id: id, gds_editor?: true, organisation: nil)
  end

  include AuthorityTestHelper

  test 'can create a new fatality notice' do
    assert enforcer_for(gds_editor, FatalityNotice).can?(:create)
  end

  test 'can see a fatality notice that is not access limited' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:see)
  end

  test 'can see a fatality notice that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = gds_editor
    user.stubs(:organisation).returns(org)
    edition = limited_fatality_notice([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see a fatality notice that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_fatality_notice([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to a fatality notice they are not allowed to see' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_fatality_notice([org2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new edition of a fatality notice that is not access limited' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:create)
  end

  test 'can make changes to a fatality notice that is not access limited' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:update)
  end

  test 'can make a fact check request for a edition' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:make_fact_check)
  end

  test 'can view fact check requests on a edition' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:review_fact_check)
  end

  test 'can publish a fatality notice' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:publish)
  end

  test 'cannot publish a fatality notice we created' do
    me = gds_editor
    refute enforcer_for(me, normal_fatality_notice(me)).can?(:publish)
  end

  test 'can reject a fatality notice' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:reject)
  end

  test 'can force publish a fatality notice' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:force_publish)
  end

  test 'can force publish a fatality notice we created' do
    me = gds_editor
    assert enforcer_for(me, normal_fatality_notice(me)).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on fatality notices they didn\'t force publish' do
    assert enforcer_for(gds_editor(10), force_published_fatality_notice(gds_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on fatality notices they did force publish' do
    me = gds_editor
    refute enforcer_for(me, force_published_fatality_notice(me)).can?(:approve)
  end

  test 'can limit access to a fatality notice' do
    assert enforcer_for(gds_editor, normal_fatality_notice).can?(:limit_access)
  end

  test 'cannot unpublish a fatality notice' do
    refute enforcer_for(gds_editor, normal_fatality_notice).can?(:unpublish)
  end
end
