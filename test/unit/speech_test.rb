require "test_helper"

class SpeechTest < EditionTestCase
  should_allow_image_attachments
  should_allow_a_role_appointment
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test "should be able to relate to other editions" do
    article = build(:speech)
    assert article.can_be_related_to_policies?
  end

  test "should be invalid without a speech type" do
    speech = build(:speech, speech_type: nil)
    refute speech.valid?
  end

  test "should be invalid without a role_appointment" do
    speech = build(:speech, role_appointment: nil)
    refute speech.valid?
  end

  test "should be invalid without a delivered_on" do
    speech = build(:speech, delivered_on: nil)
    refute speech.valid?
  end

  test "should be valid without a location" do
    speech = build(:speech, location: nil)
    assert speech.valid?
  end

  test "create should populate organisations based on the role_appointment that delivered the speech" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:role_appointment, role: ministerial_role)
    speech = create(:speech, role_appointment: role_appointment)

    assert_equal [organisation], speech.organisations
  end

  test "save should populate organisations based on the role_appointment that delivered the speech" do
    speech = create(:speech)
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:role_appointment, role: ministerial_role)
    speech.update_attributes!(role_appointment: role_appointment)

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

  test "#person should return the person who gave the speech" do
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    person = create(:person)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:speech, role_appointment: role_appointment)

    assert_equal person, speech.person
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
end
