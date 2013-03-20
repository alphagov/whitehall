require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class WorldEditorWorldwidePriorityTest < ActiveSupport::TestCase
  def world_editor(world_locations, id = 1)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, world_editor?: true,
                   organisation: nil, world_locations: world_locations || [])
  end

  include AuthorityTestHelper

  test 'can create a new edition' do
    assert enforcer_for(world_editor(['hat land']), WorldwidePriority).can?(:create)
  end

  test 'can see a worldwide priority that is not access limited if it is about their location' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'can see a worldwide priority about their location that is access limited if it is limited to their organisation' do
    org = 'organisation'
    user = world_editor(['hat land', 'tie land'])
    user.stubs(:organisation).returns(org)
    edition = with_locations(limited_worldwide_priority([org]), ['shirt land', 'hat land'])
    assert enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see a worldwide priority about their locaiton that is access limited if it is limited an organisation they don\'t belong to' do
    org1 = 'organisation_1'
    org2 = 'organisation_2'
    user = world_editor(['hat land', 'tie land'])
    user.stubs(:organisation).returns(org1)
    edition = with_locations(limited_worldwide_priority([org2]), ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see a worldwide priority that is not about their location' do
    user = world_editor(['tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land'])
    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to a worldwide priority they are not allowed to see' do
    user = world_editor(['tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land'])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'can create a new edition of a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:create)
  end

  test 'can make changes to a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:update)
  end

  test 'can delete a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:delete)
  end

  test 'can make a fact check request for a edition that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:make_fact_check)
  end

  test 'can view fact check requests on a edition that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:review_fact_check)
  end

  test 'can publish a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:publish)
  end

  test 'can reject a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:reject)
  end

  test 'can force publish a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:force_publish)
  end

  test 'can make editorial remarks that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:make_editorial_remark)
  end

  test 'can review editorial remarks that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on editions about their location and not access limited that they didn\'t force publish' do
    user = world_editor(['hat land', 'tie land'], 10)
    edition = with_locations(force_published_worldwide_priority(world_editor(['shirt land'], 100)), ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on editions about their location and not access limited that they did force publish' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(force_published_worldwide_priority(user), ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:approve)
  end

  test 'can limit access to a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    assert enforcer_for(user, edition).can?(:limit_access)
  end

  test 'cannot unpublish a worldwide priority that is about their location and not access limited' do
    user = world_editor(['hat land', 'tie land'])
    edition = with_locations(normal_worldwide_priority, ['shirt land', 'hat land'])

    refute enforcer_for(user, edition).can?(:unpublish)
  end
end
