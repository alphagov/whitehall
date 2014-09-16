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

  test '#taggable_ministerial_role_appointments_cache_digest changes when a role appointment is updated' do
    role_appointment = Timecop.travel 1.year.ago do
      create(:ministerial_role_appointment, started_at: 1.day.ago)
    end
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest
    role_appointment.update_attributes!(ended_at: 1.minute.ago)

    refute_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test '#taggable_ministerial_role_appointments_cache_digest changes when a filled ministerial role is updated' do
    role_appointment = Timecop.travel 1.year.ago do
      create(:ministerial_role_appointment, started_at: 1.day.ago)
    end
    role = role_appointment.role
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest
    role.update_attributes!(name: 'Updated the Role name')

    refute_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test '#taggable_ministerial_role_appointments_cache_digest changes when a person in a role is updated' do
    role_appointment = Timecop.travel 1.year.ago do
      create(:ministerial_role_appointment, started_at: 1.day.ago)
    end
    person = role_appointment.person
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest
    person.update_attributes!(surname: 'Smith')

    refute_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end
end
