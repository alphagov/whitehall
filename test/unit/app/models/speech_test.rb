require "test_helper"

class SpeechTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_allow_a_role_appointment
  should_protect_against_xss_and_content_attacks_on :speech, :title, :body, :summary, :change_note

  test "should be invalid without a speech type" do
    speech = build(:speech, speech_type: nil)
    assert_not speech.valid?
  end

  %i[deleted superseded].each do |state|
    test "#{state} editions are valid without a delivered on date" do
      speech = build(:speech, state:, delivered_on: nil)
      assert speech.valid?
    end

    test "#{state} editions with a blank delivered_on date have no first_public_at" do
      speech = build(:speech, state:, delivered_on: nil)
      assert_nil speech.first_public_at
    end
  end

  %i[draft scheduled published submitted rejected].each do |state|
    test "#{state} editions are not valid without a delivered on date" do
      edition = build(:speech, state:, delivered_on: nil)
      assert_not edition.valid?
    end
  end

  test "should be valid without a location" do
    speech = build(:speech, location: nil)
    assert speech.valid?
  end

  test "should be invalid without a role_appointment" do
    speech = build(:speech, role_appointment: nil)
    assert_not speech.valid?
  end

  test "should be invalid without a person_override and no role_appointment" do
    speech = build(:speech, role_appointment: nil, person_override: nil)
    assert_not speech.valid?
  end

  test "does not require an organisation or role appointment if a person_override is given" do
    speech = build(:speech, person_override: "The Queen", role_appointment: nil, create_default_organisation: false)
    assert speech.person_override?
    speech.save!
    assert_equal [], speech.reload.organisations
  end

  test "#display_type returns en locale values" do
    {
      SpeechType::Transcript => "Transcript",
      SpeechType::DraftText => "Draft text",
      SpeechType::SpeakingNotes => "Speaking notes",
      SpeechType::WrittenStatement => "Written statement to Parliament",
      SpeechType::OralStatement => "Oral statement to Parliament",
      SpeechType::AuthoredArticle => "Authored article",
    }.each do |type, display_type_value|
      speech = build(:speech, speech_type: type)
      assert_equal display_type_value, speech.display_type
    end
  end

  test "creating a new draft should not associate speech with duplicate organisations" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person:)
    speech = create(:published_speech, role_appointment:)
    new_draft = speech.create_draft(create(:user))
    assert_equal 1, new_draft.edition_organisations.count
  end

  test "#person should return the person who gave the speech" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person:)
    speech = create(:speech, role_appointment:)

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
    role_appointment = create(:role_appointment, role: ministerial_role, person:, started_at: 10.days.ago, ended_at: 2.days.ago)
    speech = create(:speech, role_appointment:)
    _subsequent_role_appointment = create(:role_appointment, role: ministerial_role, started_at: 1.day.ago)

    assert_equal person, speech.person
  end

  test "delivered_by_minister? returns true for ministerial role appointments" do
    assert build(:speech, role_appointment: build(:ministerial_role_appointment)).delivered_by_minister?
  end

  test "delivered_by_minister? returns false for all other appointments" do
    assert_not build(:speech, role_appointment: build(:board_member_role_appointment)).delivered_by_minister?
  end

  test "can associate a speech with a topical event" do
    speech = create(:speech)
    speech.topical_events << TopicalEvent.new(name: "foo", description: "bar", summary: "test")
    assert speech.can_be_associated_with_topical_events?
    assert_equal 1, speech.topical_events.size
  end

  test "should be translatable" do
    assert build(:speech).translatable?
  end

  test "is not translatable when non-English" do
    assert_not build(:speech, primary_locale: :es).translatable?
  end

  test "#government returns the government active on the delivered_on date" do
    create(:current_government)
    previous_government = create(:previous_government)
    speech = create(:speech, first_published_at: 1.day.ago, delivered_on: 4.years.ago)

    assert_equal previous_government, speech.government
  end

  test "#government returns the current government for an speech delivered at an unspecified time" do
    current_government = create(:current_government)
    speech = create(:deleted_speech, delivered_on: nil)
    assert_equal current_government, speech.government
  end

  test "#government returns the current government for an speech in the future" do
    current_government = create(:current_government)
    speech = create(:speech, delivered_on: 2.weeks.from_now)
    assert_equal current_government, speech.government
  end

  test "Speech is rendered by frontend" do
    assert_equal Speech.new.rendering_app, Whitehall::RenderingApp::FRONTEND
  end
end
