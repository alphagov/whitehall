require "test_helper"

class SpeechTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    speech = build(:speech)
    assert speech.valid?
  end

  test "should be able to relate to other documents" do
    article = build(:news_article)
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
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:speech, role_appointment: role_appointment)
    subsequent_role_appointment = create(:role_appointment, role: ministerial_role)

    assert_equal person, speech.person
  end
end
