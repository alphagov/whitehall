require 'unit/whitehall/authority/authority_test_helper'
require 'ostruct'

class WorldWriterFatalityNoticeTest < ActiveSupport::TestCase
  def fatality_world_writer(world_locations, id = 1)
    o = OpenStruct.new(id: id, handles_fatalities?: true)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, world_editor?: false,
                   world_writer?: true, organisation: o,
                   world_locations: world_locations || [])
  end

  def normal_world_writer(world_locations, id = 1)
    o = OpenStruct.new(id: id, handles_fatalities?: false)
    OpenStruct.new(id: id, gds_editor?: false,
                   departmental_editor?: false, world_editor?: false,
                   world_writer?: true, organisation: o,
                   world_locations: world_locations || [])
  end

  include AuthorityTestHelper

  test 'cannot create a new fatality notice about their location if their organisation cannot handle fatalities' do
    refute enforcer_for(normal_world_writer(['hat land']), FatalityNotice).can?(:create)
  end

  test 'cannot create a new fatality notice about their location even if their organisation can handle fatalities' do
    refute enforcer_for(fatality_world_writer(['hat land']), FatalityNotice).can?(:create)
  end

  test 'cannot see a fatality notice about their location if their organisation cannot handle fatalities' do
    user = normal_world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_fatality_notice, ['shirt land', 'hat land'])
    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot see a fatality notice about their location even if their organisation can handle fatalities' do
    user = fatality_world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_fatality_notice, ['shirt land', 'hat land'])
    refute enforcer_for(user, edition).can?(:see)
  end

  test 'cannot do anything to a fatality notice about their location if their organisation cannot handle fatalities' do
    user = normal_world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_fatality_notice, ['shirt land', 'hat land'])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end

  test 'cannot do anything to a fatality notice about their location even if their organisation can handle fatalities' do
    user = fatality_world_writer(['hat land', 'tie land'])
    edition = with_locations(normal_fatality_notice, ['shirt land', 'hat land'])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      refute enforcer.can?(action)
    end
  end
end
