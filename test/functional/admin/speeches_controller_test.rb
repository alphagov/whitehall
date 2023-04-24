require "test_helper"

class Admin::SpeechesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @current_user.permissions << "Preview design system"
  end

  should_be_an_admin_controller

  should_allow_creating_of :speech
  should_allow_editing_of :speech

  should_allow_association_between_world_locations_and :speech
  should_allow_attached_images_for :speech
  should_prevent_modification_of_unmodifiable :speech
  should_allow_scheduled_publication_of :speech
  should_allow_access_limiting_of :speech
  should_allow_association_with_topical_events :speech

  view_test "new displays speech fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name='edition[speech_type_id]']"
      assert_select "select[name='edition[role_appointment_id]']"
      assert_select "input[name='edition[person_override]']"
      assert_select "select[name*='edition[delivered_on']", count: 5
      assert_select "input[name='edition[location]'][type='text']"
    end
  end

  view_test "edit renders subtype guidance" do
    speech = create(:speech)

    get :edit, params: { id: speech }

    assert_select "form#edit_edition" do
      assert_select "select[name='edition[speech_type_id]']"
      assert_select "select[name='edition[role_appointment_id]']"
      assert_select "input[name='edition[person_override]']"
      assert_select "select[name*='edition[delivered_on']", count: 5
      assert_select "input[name='edition[location]'][type='text']"
      assert_select ".js-app-view-edition-form__subtype-format-advice", text: "Use this subformat for… A verbatim report of exactly what the speaker said (checked against delivery)."
    end
  end

  test "create should create a new speech" do
    role_appointment = create(:role_appointment)
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type:, role_appointment_id: role_appointment.id)

    post :create, params: { edition: attributes }

    assert speech = Speech.last
    assert_equal speech_type, speech.speech_type
    assert_equal role_appointment, speech.role_appointment
    assert_equal attributes[:delivered_on], speech.delivered_on
    assert_equal attributes[:location], speech.location
  end

  test "create should create a new speech without a real person" do
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type:, person_override: "The Queen", speaker_radios: "no")

    post :create, params: { edition: attributes }

    assert speech = Speech.last
    assert_equal speech_type, speech.speech_type
    assert_equal "The Queen", speech.person_override
    assert_equal attributes[:delivered_on], speech.delivered_on
    assert_equal attributes[:location], speech.location
  end

  view_test "create on unsuccessful save it clears the person_override field when the speaker has a profile on GOV.UK radio is selected" do
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type:, person_override: "The Queen", title: nil)

    post :create, params: { edition: attributes }

    assert_select "#edition_person_override", ""
  end

  view_test "create on unsuccessful save it clears the role_appointment_id field when the speaker does not have a profile on GOV.UK radio is selected" do
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type:, person_override: "The Queen", title: nil, speaker_radios: "no")

    post :create, params: { edition: attributes }

    assert_select "#edition_role_appointment_id option[selected]", count: 0
  end

  test "update should save modified speech attributes" do
    speech = create(:speech)
    new_role_appointment = create(:role_appointment)
    new_delivered_on = speech.delivered_on + 1
    new_speech_type = SpeechType::Transcript

    put :update,
        params: { id: speech.id,
                  edition: {
                    role_appointment_id: new_role_appointment.id,
                    speech_type_id: new_speech_type.id,
                    delivered_on: new_delivered_on,
                    location: "new-location",
                  } }

    speech = Speech.last
    assert_equal new_speech_type, speech.speech_type
    assert_equal new_role_appointment, speech.role_appointment
    assert_equal new_delivered_on, speech.delivered_on
    assert_equal "new-location", speech.location
  end

  view_test "update on unsuccessful save it clears the person_override field when the speaker has a profile on GOV.UK radio is selected" do
    speech = create(:speech)
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type:, person_override: "The Queen", title: nil)

    post :update, params: { id: speech.id, edition: attributes }

    assert_select "#edition_person_override", ""
  end

  view_test "update on unsuccessful save it clears the role_appointment_id field when the speaker does not have a profile on GOV.UK radio is selected" do
    speech = create(:speech)
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type:, person_override: "The Queen", title: nil, speaker_radios: "no")

    post :update, params: { id: speech.id, edition: attributes }

    assert_select "#edition_role_appointment_id option[selected]", count: 0
  end

private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:role_appointment, :speech_type).reverse_merge(
      role_appointment_id: create(:role_appointment).id,
      speech_type_id: SpeechType::Transcript.id,
      speaker_radios: "yes",
    )
  end
end
