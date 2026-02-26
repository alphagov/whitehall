require "test_helper"

class Admin::TaggableContentHelperTest < ActionView::TestCase
  test "#taggable_topical_events_container returns an array of select options for all topical events ordered by name" do
    event_c = create(:topical_event, name: "event C")
    event_b = create(:topical_event, name: "event B")
    event_a = create(:topical_event, name: "event A")

    assert_equal [
      { text: "event A", value: event_a.id, selected: false },
      { text: "event B", value: event_b.id, selected: true },
      { text: "event C", value: event_c.id, selected: false },
    ],
                 taggable_topical_events_container([event_b.id])
  end

  test "#taggable_topical_event_documents_container returns an array of select options for all topical event documents" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("topical_event"))
    event_c = create(:standard_edition, title: "event C", configurable_document_type: "topical_event")
    event_b = create(:standard_edition, title: "event B", configurable_document_type: "topical_event")
    event_a = create(:standard_edition, title: "event A", configurable_document_type: "topical_event")

    assert_equal [
      { text: "event A", value: event_a.document.id, selected: false },
      { text: "event B", value: event_b.document.id, selected: true },
      { text: "event C", value: event_c.document.id, selected: false },
    ],
                 taggable_topical_event_documents_container([event_b.document.id])
  end

  test "#taggable_organisations_container returns an array of select_name/ID pairs for all Organisations" do
    organisation_c = create(:organisation, name: "Organisation C", acronym: "OC")
    organisation_b = create(:organisation, name: "Organisation B", acronym: "OB")
    organisation_a = create(:organisation, name: "Organisation A", acronym: "OA")

    assert_equal [
      { text: "Organisation A (OA)", value: organisation_a.id, selected: false },
      { text: "Organisation B (OB)", value: organisation_b.id, selected: false },
      { text: "Organisation C (OC)", value: organisation_c.id, selected: false },
    ],
                 taggable_organisations_container
  end

  test "#taggable_ministerial_role_appointments_container returns an array of label/ID pairs for ministerial role appointments" do
    ministry = create(:organisation, name: "Ministry for Rocks and Bones")
    leader   = create(:ministerial_role, name: "Leader", organisations: [ministry])
    deputy   = create(:ministerial_role, name: "Deputy Leader", organisations: [ministry])

    fred     = create(:person, forename: "Fred", surname: "Flintstone")
    joe      = create(:person, forename: "Joe", surname: "Rockhead")
    slate    = create(:person, forename: "Mr.", surname: "Slate")

    deputy_leader_appointment  = create(:role_appointment, role: deputy, person: joe, started_at: Date.new(2009, 5, 3))
    current_leader_appointment = create(:role_appointment, role: leader, person: fred, started_at: Date.new(2009, 5, 4))
    old_leader_appointment     = create(
      :role_appointment,
      role: leader,
      person: slate,
      started_at: Date.new(1960, 5, 12),
      ended_at: Date.new(1972, 5, 14),
    )

    assert_equal [
      { text: "Fred Flintstone, Leader, Ministry for Rocks and Bones", value: current_leader_appointment.id, selected: false },
      { text: "Joe Rockhead, Deputy Leader, Ministry for Rocks and Bones", value: deputy_leader_appointment.id, selected: false },
      { text: "Mr. Slate, Leader (12 May 1960 to 14 May 1972), Ministry for Rocks and Bones", value: old_leader_appointment.id, selected: false },
    ],
                 taggable_ministerial_role_appointments_container
  end

  test "#taggable_ministerial_role_appointments_container does not include the dates of previous appointments for the same role in the label text" do
    ministry = create(:organisation, name: "Ministry for Rocks and Bones")
    leader = create(:ministerial_role, name: "Leader", organisations: [ministry])

    joe = create(:person, forename: "Joe", surname: "Rockhead")
    slate = create(:person, forename: "Mr.", surname: "Slate")
    granite = create(:person, forename: "Karen", surname: "Granite")

    old_leader_appointment = create(
      :role_appointment,
      role: leader,
      person: joe,
      started_at: Date.new(2006, 5, 12),
      ended_at: Date.new(2011, 5, 11),
    )

    older_leader_appointment = create(
      :role_appointment,
      role: leader,
      person: granite,
      started_at: Date.new(2003, 5, 12),
      ended_at: Date.new(2006, 5, 11),
    )
    current_leader_appointment = create(:role_appointment, role: leader, person: slate)

    assert_equal [
      { text: "Mr. Slate, Leader, Ministry for Rocks and Bones", value: current_leader_appointment.id, selected: false },
      { text: "Joe Rockhead, Leader (12 May 2006 to 11 May 2011), Ministry for Rocks and Bones", value: old_leader_appointment.id, selected: false },
      { text: "Karen Granite, Leader (12 May 2003 to 11 May 2006), Ministry for Rocks and Bones", value: older_leader_appointment.id, selected: false },
    ],
                 taggable_ministerial_role_appointments_container
  end

  test "#taggable_role_appointments_container returns an array of label/ID pairs for all role appointments" do
    ministry        = create(:organisation, name: "Ministry for Funk")
    minister        = create(:ministerial_role, name: "Minister of Funk", organisations: [ministry])
    board_member    = create(:board_member_role, name: "Board Member", organisations: [ministry])

    brown   = create(:person, surname: "Brown", forename: "James")
    clinton = create(:person, surname: "Clinton", forename: "George")
    richard = create(:person, surname: "Richard", forename: "Little")

    minister_appointment     = create(:role_appointment, role: minister, person: brown)
    board_member_appointment = create(:role_appointment, role: board_member, person: clinton)
    old_minister_appointment = create(
      :role_appointment,
      role: minister,
      person: richard,
      started_at: Date.new(1932, 12, 5),
      ended_at: Date.new(1972, 5, 14),
    )

    assert_equal [
      { text: "James Brown, Minister of Funk, Ministry for Funk", value: minister_appointment.id, selected: false },
      { text: "George Clinton, Board Member, Ministry for Funk", value: board_member_appointment.id, selected: false },
      { text: "Little Richard, Minister of Funk (05 December 1932 to 14 May 1972), Ministry for Funk", value: old_minister_appointment.id, selected: false },
    ],
                 taggable_role_appointments_container
  end

  test "#taggable_detailed_guides_container returns an array of label/ID pairs for all active detailed guides" do
    guide_b = create(:published_detailed_guide, title: "Guide B")
    guide_a = create(:draft_detailed_guide, title: "Guide A")
    _guide_x = create(:superseded_detailed_guide, title: "Guide X")
    guide_c = create(:submitted_detailed_guide, title: "Guide C")

    assert_equal [
      { text: guide_a.title, value: guide_a.id, selected: false },
      { text: guide_b.title, value: guide_b.id, selected: false },
      { text: guide_c.title, value: guide_c.id, selected: false },
    ],
                 taggable_detailed_guides_container
  end

  test "#taggable_statistical_data_sets_container returns an array of label/Document ID pairs for all statistical data sets" do
    data_set1 = create(:draft_statistical_data_set)
    data_set2 = create(:published_statistical_data_set)
    data_set3 = create(:submitted_statistical_data_set)

    assert_equal [
      { text: data_set1.title, value: data_set1.document_id, selected: false },
      { text: data_set2.title, value: data_set2.document_id, selected: false },
      { text: data_set3.title, value: data_set3.document_id, selected: false },
    ],
                 taggable_statistical_data_sets_container
  end

  test "#taggable_world_locations_container returns an array of label/ID pairs for all active world locations" do
    location_a = create(:world_location, name: "Andorra", active: true)
    location_c = create(:world_location, name: "Croatia", active: true)
    location_b = create(:world_location, name: "Brazil", active: true)
    create(:world_location, name: "United Kingdom", active: false)

    assert_equal [
      { text: "Andorra", value: location_a.id, selected: false },
      { text: "Brazil", value: location_b.id, selected: false },
      { text: "Croatia", value: location_c.id, selected: false },
    ],
                 taggable_world_locations_container
  end

  test "#taggable_alternative_format_providers_container returns an array of label/ID pairs for organisation alternative format providers" do
    organisation_h = create(:organisation, name: "Department for Hair and Makeup")
    organisation_m = create(:organisation, alternative_format_contact_email: "barry@strange-fruit.uk", name: "Ministry of Strange Fruit")
    organisation_t = create(:organisation, alternative_format_contact_email: "lee.perry@melodica.uk", name: "Department for the Preseveration of Melodicas")

    assert_equal [
      { text: "Department for Hair and Makeup (-)", value: organisation_h.id, selected: false },
      { text: "Department for the Preseveration of Melodicas (lee.perry@melodica.uk)", value: organisation_t.id, selected: false },
      { text: "Ministry of Strange Fruit (barry@strange-fruit.uk)", value: organisation_m.id, selected: false },
    ],
                 taggable_alternative_format_providers_container
  end

  test "#taggable_ministerial_role_appointments_cache_digest changes when a role appointment is updated" do
    role_appointment = Timecop.travel 1.year.ago do
      create(:ministerial_role_appointment, started_at: 1.day.ago)
    end
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    role_appointment.update!(ended_at: 1.minute.ago)
    assert_not_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test "#taggable_ministerial_role_appointments_cache_digest changes when a filled ministerial role is updated" do
    Timecop.travel 1.year.ago
    mininsterial_role_appointment = create(:ministerial_role_appointment)
    other_role_appointment = create(:board_member_role_appointment)
    minister_role = mininsterial_role_appointment.role
    other_role = other_role_appointment.role
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest
    Timecop.return

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    other_role.update!(name: "Updated the Board Member Role name")
    assert_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    minister_role.update!(name: "Updated the Role name")
    assert_not_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test "#taggable_ministerial_role_appointments_cache_digest changes when a person in a role is updated" do
    role_appointment = Timecop.travel 1.year.ago do
      create(:ministerial_role_appointment, started_at: 1.day.ago)
    end
    person = role_appointment.person
    current_cache_digest = taggable_ministerial_role_appointments_cache_digest

    clear_memoization_for("taggable_ministerial_role_appointments_cache_digest")
    person.update!(surname: "Smith")
    assert_not_equal current_cache_digest, taggable_ministerial_role_appointments_cache_digest
  end

  test "#taggable_role_appointments_cache_digest changes when any filled role is updated" do
    Timecop.travel 1.year.ago
    mininsterial_role_appointment = create(:ministerial_role_appointment)
    other_role_appointment = create(:board_member_role_appointment)
    minister_role = mininsterial_role_appointment.role
    other_role = other_role_appointment.role
    current_cache_digest = taggable_role_appointments_cache_digest
    Timecop.return

    clear_memoization_for("taggable_role_appointments_cache_digest")
    other_role.update!(name: "Updated the Board Member Role name")
    assert_not_equal current_cache_digest, taggable_role_appointments_cache_digest

    clear_memoization_for("taggable_role_appointments_cache_digest")
    minister_role.update!(name: "Updated the Role name")
    assert_not_equal current_cache_digest, taggable_role_appointments_cache_digest
  end

private

  # The cache digest calculations are memoized in the helper methods, which
  # means we need to clear the stored value if we want to test that they
  # are recalculated correctly between requests
  def clear_memoization_for(digest_name)
    remove_instance_variable("@#{digest_name}".to_sym)
  end
end
