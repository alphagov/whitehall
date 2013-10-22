require "test_helper"

class SpeechTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_allow_a_role_appointment
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test "should be able to relate to other editions" do
    article = build(:speech)
    assert article.can_be_related_to_policies?
  end

  test "can be associated with worldwide priorities" do
    assert Speech.new.can_be_associated_with_worldwide_priorities?
  end

  test "should be invalid without a speech type" do
    speech = build(:speech, speech_type: nil)
    refute speech.valid?
  end

  [:imported, :deleted].each do |state|
    test "#{state} editions are valid when the type is 'imported-awaiting-type'" do
      speech = build(:speech, state: state, speech_type: SpeechType.find_by_slug('imported-awaiting-type'))
      assert speech.valid?
    end

    test "#{state} editions are valid without a delivered on date" do
      speech = build(:speech, state: state, delivered_on: nil)
      assert speech.valid?
    end

    test "#{state} editions with a blank delivered_on date have no first_public_at" do
      speech = build(:speech, state: state, delivered_on: nil)
      assert_nil speech.first_public_at
    end
  end

  [:draft, :scheduled, :published, :submitted, :rejected].each do |state|
    test "#{state} editions are not valid when the publication type is 'imported-awaiting-type'" do
      edition = build(:speech, state: state, speech_type: SpeechType.find_by_slug('imported-awaiting-type'))
      refute edition.valid?
    end

    test "#{state} editions are not valid without a delivered on date" do
      edition = build(:speech, state: state, delivered_on: nil)
      refute edition.valid?
    end
  end

  test "should be valid without a location" do
    speech = build(:speech, location: nil)
    assert speech.valid?
  end

  test "should be invalid without a role_appointment" do
    speech = build(:speech, role_appointment: nil)
    refute speech.valid?
  end

  test "should be invalid without a person_override and no role_appointment" do
    speech = build(:speech, role_appointment: nil, person_override: nil)
    refute speech.valid?
  end

  test "should be valid with a person_override and no role_appointment" do
    speech = build(:speech, role_appointment: nil, person_override: "The Queen")
    assert speech.valid?
  end

  test "should be invalid if role_appointment has no associated organisation" do
    speech = build(:speech, role_appointment: build(:role_appointment, role: nil))
    refute speech.valid?
  end

  test "is valid if can have some invalid data and role_appointment has no associated organisation" do
    speech = build(:speech, role_appointment: nil, state: 'imported')
    assert speech.valid?
  end

  test "associates itself with role appointments organisation on save" do
    speech = build(:speech)
    speech.save!
    assert_equal speech.role_appointment.role.organisations, speech.reload.organisations
  end

  test "should not associates itself via role appointments organisation on save with a person_override" do
    speech = build(:speech, person_override: "The Queen", role_appointment: nil, create_default_organisation: false)
    assert speech.person_override?
    speech.save!
    assert_equal [], speech.reload.organisations
  end

  test "has statement to parliament display type if written statement" do
    speech = build(:speech, speech_type: SpeechType::WrittenStatement)
    assert_equal "Statement to Parliament", speech.display_type
  end

  test "has statement to parliament display type if oral statement" do
    speech = build(:speech, speech_type: SpeechType::OralStatement)
    assert_equal "Statement to Parliament", speech.display_type
  end

  test "has speech display type if not oral statement or written statement" do
    (SpeechType.all - [SpeechType::WrittenStatement, SpeechType::OralStatement]).each do |type|
      speech = build(:speech, speech_type: type)
      assert_equal "Speech", speech.display_type
    end
  end

  test "create should populate organisations based on the role_appointment that delivered the speech, and mark them as lead" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:role_appointment, role: ministerial_role)
    speech = create(:speech, role_appointment: role_appointment)

    assert_equal [organisation], speech.organisations
    assert_equal [organisation], speech.lead_organisations
  end

  test "imported speeches without role_appointments yet will preserve organisations for now" do
    organisation = create(:organisation)
    speech = build(:speech, organisations: [organisation], state: 'imported', role_appointment: nil)
    speech.save
    assert_equal [organisation], speech.organisations
  end

  test "save should populate lead organisations based on the role_appointment that delivered the speech, and mark them as lead" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:role_appointment, role: ministerial_role)
    speech = create(:speech, role_appointment: role_appointment)

    assert_equal [organisation], speech.lead_organisations
    assert_equal [organisation], speech.organisations
  end

  test "save should set the lead organisations, with a person_override" do
    organisation = create(:organisation)
    speech = create(:speech, lead_organisations: [organisation], person_override: "The Queen")

    assert_equal [organisation], speech.lead_organisations
    assert_equal [organisation], speech.organisations
  end

  test "creating a new draft should not associate speech with duplicate organisations" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:published_speech, role_appointment: role_appointment)
    new_draft = speech.create_draft(create(:user))
    assert_equal 1, new_draft.edition_organisations.count
  end

  test "editing a speech should reassign organisations based on role_appointment" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    ministerial_role_1 = create(:ministerial_role, organisations: [organisation_1])
    ministerial_role_2 = create(:ministerial_role, organisations: [organisation_2])

    role_appointment_1 = create(:role_appointment, role: ministerial_role_1)
    role_appointment_2 = create(:role_appointment, role: ministerial_role_2)

    speech = create(:speech, role_appointment: role_appointment_1)
    speech.update_attributes!(role_appointment: role_appointment_2)

    assert_equal [organisation_2], speech.organisations(true)
  end

  test "editing a speech should reassign organisations based on role_appointment if removing a person_override" do
    organisation_1 = create(:organisation)
    ministerial_role_1 = create(:ministerial_role, organisations: [organisation_1])
    role_appointment_1 = create(:role_appointment, role: ministerial_role_1)

    speech = create(:speech, person_override: "The Queen", role_appointment: nil)
    speech.update_attributes!(role_appointment: role_appointment_1, person_override: nil)

    assert_equal [organisation_1], speech.organisations(true)
  end

  test "organisation association to edition preserved when edition state changes" do
    user = create(:departmental_editor)
    organisation = create(:ministerial_department)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:role_appointment, role: ministerial_role)
    speech = create(:speech, :draft,
      scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2,
      role_appointment: role_appointment)
    speech.force_schedule!
    assert_equal [speech], organisation.reload.editions
  end

  test "#person should return the person who gave the speech" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:speech, role_appointment: role_appointment)

    assert_equal person, speech.person
  end

  test "#person should return the person who gave the speech when person_override is set" do
    person = "The Queen"
    speech = create(:speech, role_appointment: nil, person_override: person)

    assert_equal person, speech.person_override
  end

  test "#person should return the person who gave the speech even if they are no longer in the same role" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person, started_at: 10.days.ago, ended_at: 2.days.ago)
    speech = create(:speech, role_appointment: role_appointment)
    subsequent_role_appointment = create(:role_appointment, role: ministerial_role, started_at: 1.day.ago)

    assert_equal person, speech.person
  end

  test "delivered_by_minister? returns true for ministerial role appointments" do
    assert build(:speech, role_appointment: build(:ministerial_role_appointment)).delivered_by_minister?
  end

  test "delivered_by_minister? returns false for all other appointments" do
    refute build(:speech, role_appointment: build(:board_member_role_appointment)).delivered_by_minister?
  end

  test "can associate a speech with a topical event" do
    speech = create(:speech)
    speech.topical_events << TopicalEvent.new(name: "foo", description: "bar")
    assert speech.can_be_associated_with_topical_events?
    assert_equal 1, speech.topical_events.size
  end

  test "search_index contains person and organisation via role appointment" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:published_speech, title: "my title", speech_type: SpeechType::Transcript, role_appointment: role_appointment)
    assert_equal [person.slug], speech.search_index['people']
    assert_equal [organisation.slug], speech.search_index['organisations']
  end

  test "search_index does not contain person when person_override is set" do
    speech = create(:published_speech, title: "my title", speech_type: SpeechType::Transcript, role_appointment: nil, person_override: "The Queen")
    refute speech.search_index.has_key?('people')
  end

  test 'search_format_types tags the speech as a speech and announcement' do
    speech = build(:speech)
    assert speech.search_format_types.include?('speech')
    assert speech.search_format_types.include?('announcement')
  end

  test 'search_format_types includes search_format_types of the speech_type' do
    speech_type = mock
    speech_type.responds_like(SpeechType.new)
    speech_type.stubs(:search_format_types).returns (['stuff-innit', 'other-thing'])
    speech = build(:speech)
    speech.stubs(:speech_type).returns(speech_type)
    assert speech.search_format_types.include?('stuff-innit')
    assert speech.search_format_types.include?('other-thing')
  end

  test "should be translatable" do
    assert build(:speech).translatable?
  end

  test "is not translatable when non-English" do
    refute build(:speech, locale: :es).translatable?
  end
end
