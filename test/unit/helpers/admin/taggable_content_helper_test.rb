require 'test_helper'

class Admin::TaggableContentHelperTest < ActionView::TestCase
  test '#taggable_topics_container returns an array of name/ID pairs for all Topics' do
    topic_b = create(:topic, name: 'Topic B')
    topic_a = create(:topic, name: 'Topic A')
    topic_c = create(:topic, name: 'Topic C')

    assert_equal [
      ['Topic A', topic_a.id],
      ['Topic B', topic_b.id],
      ['Topic C', topic_c.id],
    ], taggable_topics_container
  end

  test '#taggable_topical_events_container returns an array of name/ID pairs for all TopicalEvents' do
    event_a = create(:topical_event, name: 'Event A')
    event_c = create(:topical_event, name: 'Event C')
    event_b = create(:topical_event, name: 'Event B')

    assert_equal [
      ['Event A', event_a.id],
      ['Event B', event_b.id],
      ['Event C', event_c.id],
    ], taggable_topical_events_container
  end

  test '#taggable_organisations_container returns an array of select_name/ID pairs for all Organisations' do
    organisation_c = create(:organisation, name: 'Organisation C', acronym: "OC")
    organisation_b = create(:organisation, name: 'Organisation B', acronym: "OB")
    organisation_a = create(:organisation, name: 'Organisation A', acronym: "OA")

    assert_equal [
      ['Organisation A (OA)', organisation_a.id],
      ['Organisation B (OB)', organisation_b.id],
      ['Organisation C (OC)', organisation_c.id],
    ], taggable_organisations_container
  end

  test '#taggable_ministerial_role_appointments_container returns an array of label/ID pairs for ministerial role appointments' do
    ministry = create(:organisation, name: 'Ministry for Rocks and Bones')
    leader   = create(:ministerial_role, name: 'Leader', organisations: [ministry])
    deputy   = create(:ministerial_role, name: 'Deputy Leader', organisations: [ministry])

    fred     = create(:person, forename: "Fred", surname: 'Flintstone')
    joe      = create(:person, forename: "Joe", surname: 'Rockhead')
    slate    = create(:person, forename: "Mr.", surname: 'Slate')

    deputy_leader_appointment  = create(:role_appointment, role: deputy, person: joe)
    current_leader_appointment = create(:role_appointment, role: leader, person: fred)
    old_leader_appointment     = create(:role_appointment,
                                          role: leader,
                                          person: slate,
                                          started_at: Date.new(1960, 5, 12),
                                          ended_at: Date.new(1972, 5, 14))

    assert_equal [
      ['Fred Flintstone, Leader, Ministry for Rocks and Bones', current_leader_appointment.id],
      ['Joe Rockhead, Deputy Leader, Ministry for Rocks and Bones', deputy_leader_appointment.id],
      ['Mr. Slate, Leader (12 May 1960 to 14 May 1972), Ministry for Rocks and Bones', old_leader_appointment.id],
    ], taggable_ministerial_role_appointments_container
  end

  test '#taggable_ministerial_role_appointments_container does not include the dates of previous appointments for the same role in the label text' do
    ministry = create(:organisation, name: 'Ministry for Rocks and Bones')
    leader = create(:ministerial_role, name: 'Leader', organisations: [ministry])

    joe = create(:person, forename: "Joe", surname: 'Rockhead')
    slate = create(:person, forename: "Mr.", surname: 'Slate')

    old_leader_appointment = create(:role_appointment,
                                      role: leader,
                                      person: joe,
                                      started_at: Date.new(2006, 5, 12),
                                      ended_at: Date.new(2011, 5, 11))
    current_leader_appointment = create(:role_appointment, role: leader, person: slate)

    assert_equal [
      ['Joe Rockhead, Leader (12 May 2006 to 11 May 2011), Ministry for Rocks and Bones', old_leader_appointment.id],
      ['Mr. Slate, Leader, Ministry for Rocks and Bones', current_leader_appointment.id],
    ], taggable_ministerial_role_appointments_container
  end

  test '#taggable_role_appointments_container returns an array of label/ID pairs for all role appointments' do
    ministry        = create(:organisation, name: 'Ministry for Funk')
    minister        = create(:ministerial_role, name: 'Minister of Funk', organisations: [ministry])
    board_member    = create(:board_member_role, name: 'Board Member', organisations: [ministry])

    brown   = create(:person, surname: 'Brown', forename: 'James')
    clinton = create(:person, surname: 'Clinton', forename: 'George')
    richard = create(:person, surname: 'Richard', forename: 'Little')

    minister_appointment     = create(:role_appointment, role: minister, person: brown)
    board_member_appointment = create(:role_appointment, role: board_member, person: clinton)
    old_minister_appointment = create(:role_appointment,
                                          role: minister,
                                          person: richard,
                                          started_at: Date.new(1932, 12, 5),
                                          ended_at: Date.new(1972, 5, 14))

    assert_equal [
      ['James Brown, Minister of Funk, Ministry for Funk', minister_appointment.id],
      ['George Clinton, Board Member, Ministry for Funk', board_member_appointment.id],
      ['Little Richard, Minister of Funk (05 December 1932 to 14 May 1972), Ministry for Funk', old_minister_appointment.id],
    ], taggable_role_appointments_container
  end

  test '#taggable_ministerial_roles_container returns an array of label/ID pairs for all the ministerial roles' do
    create(:board_member_role)
    minister_b = create(:ministerial_role, name: 'Minister B', organisations: [create(:organisation, name: 'Jazz Ministry')])
    minister_a = create(:ministerial_role, name: 'Minister A', organisations: minister_b.organisations)
    minister_c = create(:ministerial_role, name: 'Minister C', organisations: [create(:organisation, name: 'Ministry of Outer Space')])

    create(:role_appointment, role: minister_a, person: create(:person, forename: 'Sun', surname: 'Ra'))
    create(:role_appointment, role: minister_c, person: create(:person, forename: 'George', surname: 'Clinton'))

    assert_equal [
      ["Minister B, Jazz Ministry (Minister B)", minister_b.id],
      ["Minister C, Ministry of Outer Space (George Clinton)", minister_c.id],
      ["Minister A, Jazz Ministry (Sun Ra)", minister_a.id],
    ], taggable_ministerial_roles_container
  end

  test '#taggable_detailed_guides_container returns an array of label/ID pairs for all active detailed guides' do
    guide_b = create(:published_detailed_guide, title: 'Guide B')
    guide_a = create(:draft_detailed_guide, title: 'Guide A')
    guide_x = create(:superseded_detailed_guide, title: 'Guide X')
    guide_c = create(:submitted_detailed_guide, title: 'Guide C')

    assert_equal [
      [guide_a.title, guide_a.id],
      [guide_b.title, guide_b.id],
      [guide_c.title, guide_c.id],
    ], taggable_detailed_guides_container
  end

  test '#taggable_statistical_data_sets_container returns an array of label/Document ID pairs for all statistical data sets' do
    data_set_1 = create(:draft_statistical_data_set)
    data_set_2 = create(:published_statistical_data_set)
    data_set_3 = create(:submitted_statistical_data_set)

    assert_equal [
      [data_set_1.title, data_set_1.document_id],
      [data_set_2.title, data_set_2.document_id],
      [data_set_3.title, data_set_3.document_id],
    ], taggable_statistical_data_sets_container
  end

  test '#taggable_world_locations_container returns an array of label/ID pairs for all active world locations' do
    location_a = create(:world_location, name: 'Andorra', active: true)
    location_c = create(:world_location, name: 'Croatia', active: true)
    location_b = create(:world_location, name: 'Brazil', active: true)
    create(:world_location, name: 'United Kingdom', active: false)

    assert_equal [
      ['Andorra', location_a.id],
      ['Brazil', location_b.id],
      ['Croatia', location_c.id],
      ], taggable_world_locations_container
  end

  test '#taggable_alternative_format_providers_container returns an array of label/ID pairs for organisation alternative format providers' do
    organisation_h = create(:organisation, name: 'Department for Hair and Makeup')
    organisation_m = create(:organisation, alternative_format_contact_email: 'barry@strange-fruit.uk', name: 'Ministry of Strange Fruit')
    organisation_t = create(:organisation, alternative_format_contact_email: 'lee.perry@melodica.uk', name: 'Department for the Preseveration of Melodicas')

    assert_equal [
      ['Department for Hair and Makeup (-)', organisation_h.id],
      ['Department for the Preseveration of Melodicas (lee.perry@melodica.uk)', organisation_t.id],
      ['Ministry of Strange Fruit (barry@strange-fruit.uk)', organisation_m.id],
    ], taggable_alternative_format_providers_container
  end

  test '#taggable_document_collection_groups_container returns an array of label/ID pairs for document collection groups' do
    group1 = create(:document_collection_group, heading: 'Group 1')
    group2 = create(:document_collection_group, heading: 'Group 2')
    group3 = create(:document_collection_group, heading: 'Group 3')
    collection1 = create(:document_collection, title: 'Collection 1', groups: [group1])
    collection2 = create(:document_collection, title: 'Collection 2', groups: [group2, group3])

    assert_equal [
      ["Collection 1 (Group 1)", group1.id],
      ["Collection 2 (Group 2)", group2.id],
      ["Collection 2 (Group 3)", group3.id],
    ], taggable_document_collection_groups_container
  end

  test '#taggable_worldwide_organisations_container returns an array of label/ID pairs for worldwide organisations' do
    world_org_1 = create(:worldwide_organisation, name: 'World Org 1')
    world_org_2 = create(:worldwide_organisation, name: 'World Org 2')
    world_org_3 = create(:worldwide_organisation, name: 'World Org 3')

    assert_equal [
      ["World Org 1", world_org_1.id],
      ["World Org 2", world_org_2.id],
      ["World Org 3", world_org_3.id],
    ], taggable_worldwide_organisations_container
  end

  test '#taggable_worldwide_organisations_container only returns worldwide organisations once even if they have more than one translation' do
    world_org_1 = create(:worldwide_organisation, name: 'World Org 1', translated_into: %i[fr es])
    world_org_2 = create(:worldwide_organisation, name: 'World Org 2')

    assert_equal [
      ["World Org 1", world_org_1.id],
      ["World Org 2", world_org_2.id],
    ], taggable_worldwide_organisations_container
  end

  test '#taggable_ministerial_role_appointments_cache_digest changes when a role appointment is updated' do
    role_appointment = Timecop.travel 1.year.ago do
      create(:ministerial_role_appointment, started_at: 1.day.ago)
    end
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    role_appointment.update_attributes!(ended_at: 1.minute.ago)
    refute_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test '#taggable_ministerial_role_appointments_cache_digest changes when a filled ministerial role is updated' do
    Timecop.travel 1.year.ago
    mininsterial_role_appointment = create(:ministerial_role_appointment)
    other_role_appointment = create(:board_member_role_appointment)
    minister_role = mininsterial_role_appointment.role
    other_role = other_role_appointment.role
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest
    Timecop.return

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    other_role.update_attributes!(name: 'Updated the Board Member Role name')
    assert_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    minister_role.update_attributes!(name: 'Updated the Role name')
    refute_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test '#taggable_ministerial_role_appointments_cache_digest changes when a person in a role is updated' do
    role_appointment = Timecop.travel 1.year.ago do
      create(:ministerial_role_appointment, started_at: 1.day.ago)
    end
    person = role_appointment.person
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    person.update_attributes!(surname: 'Smith')
    refute_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test '#taggable_role_appointments_cache_digest changes when any filled role is updated' do
    Timecop.travel 1.year.ago
    mininsterial_role_appointment = create(:ministerial_role_appointment)
    other_role_appointment = create(:board_member_role_appointment)
    minister_role = mininsterial_role_appointment.role
    other_role = other_role_appointment.role
    current_cache_digest = taggable_role_appointments_cache_digest
    Timecop.return

    clear_memoization_for("taggable_role_appointments_cache_digest")
    other_role.update_attributes!(name: 'Updated the Board Member Role name')
    refute_equal current_cache_digest, taggable_role_appointments_cache_digest

    clear_memoization_for("taggable_role_appointments_cache_digest")
    minister_role.update_attributes!(name: 'Updated the Role name')
    refute_equal current_cache_digest, taggable_role_appointments_cache_digest
  end

private

  # The cache digest calculations are memoized in the helper methods, which
  # means we need to clear the stored value if we want to test that they
  # are recalculated correctly between requests
  def clear_memoization_for(digest_name)
    remove_instance_variable("@_#{digest_name}".to_sym)
  end
end
