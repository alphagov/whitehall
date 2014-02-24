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

  test "does not require an organisation or role appointment when being imported" do
    speech = build(:speech, role_appointment: nil, create_default_organisation: false, state: 'imported')
    assert speech.valid?
  end

  test "does not require an organisation or role appointment if a person_override is given" do
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

  test "creating a new draft should not associate speech with duplicate organisations" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:published_speech, role_appointment: role_appointment)
    new_draft = speech.create_draft(create(:user))
    assert_equal 1, new_draft.edition_organisations.count
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
