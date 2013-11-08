require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class GDSEditorWorldwidePriorityTest < ActiveSupport::TestCase
  def gds_editor(id = 1)
    OpenStruct.new(id: id, gds_editor?: true, organisation: nil)
  end

  include AuthorityTestHelper

  test 'can create a new WorldwidePriority' do
    assert enforcer_for(gds_editor, WorldwidePriority).can?(:create)
  end

  test 'can see a worldwide priority that is not access limited' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:see)
  end

  test 'can see an worldwide priority that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = gds_editor
    user.stubs(:organisation).returns(org)
    edition = limited_worldwide_priority([org])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see an worldwide priority that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_worldwide_priority([org2])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to an worldwide priority they are not allowed to see' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = gds_editor
    user.stubs(:organisation).returns(org1)
    edition = limited_worldwide_priority([org2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new edition of a worldwide priority that is not access limited' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:create)
  end

  test 'can make changes to a worldwide priority that is not access limited' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:update)
  end

  test 'can delete a worldwide priority that is not access limited' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:delete)
  end

  test 'can make a fact check request for a worldwide priority' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:make_fact_check)
  end

  test 'can view fact check requests on a worldwide priority' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:review_fact_check)
  end

  test 'can publish a worldwide priority' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:publish)
  end

  test 'cannot publish a worldwide priority we created' do
    me = gds_editor
    refute enforcer_for(me, normal_worldwide_priority(me)).can?(:publish)
  end

  test 'can reject a worldwide priority' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:reject)
  end

  test 'can force publish a worldwide priority' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:force_publish)
  end

  test 'can force publish a worldwide priority we created' do
    me = gds_editor
    assert enforcer_for(me, normal_worldwide_priority(me)).can?(:force_publish)
  end

  test 'can make editorial remarks' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on worldwide prioritys they didn\'t force publish' do
    assert enforcer_for(gds_editor(10), force_published_worldwide_priority(gds_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on worldwide prioritys they did force publish' do
    me = gds_editor
    refute enforcer_for(me, force_published_worldwide_priority(me)).can?(:approve)
  end

  test 'can limit access to a worldwide priority' do
    assert enforcer_for(gds_editor, normal_worldwide_priority).can?(:limit_access)
  end

  test 'cannot unpublish a worldwide priority' do
    refute enforcer_for(gds_editor, normal_worldwide_priority).can?(:unpublish)
  end
end
