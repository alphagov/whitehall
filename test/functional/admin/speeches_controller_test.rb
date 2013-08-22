require 'test_helper'

class Admin::SpeechesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :speech
  should_allow_editing_of :speech

  should_allow_speed_tagging_of :speech
  should_allow_related_policies_for :speech
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
      assert_select "select[name*='edition[delivered_on']", count: 5
      assert_select "input[name='edition[location]'][type='text']"
    end
  end

  test "create should create a new speech" do
    role_appointment = create(:role_appointment)
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type: speech_type, role_appointment_id: role_appointment.id)

    post :create, edition: attributes

    assert speech = Speech.last
    assert_equal speech_type, speech.speech_type
    assert_equal role_appointment, speech.role_appointment
    assert_equal attributes[:delivered_on], speech.delivered_on
    assert_equal attributes[:location], speech.location
  end

  test "create should create a new speech without a real person" do
    speech_type = SpeechType::Transcript
    attributes = controller_attributes_for(:speech, speech_type: speech_type, person_override: "The Queen")

    post :create, edition: attributes

    assert speech = Speech.last
    assert_equal speech_type, speech.speech_type
    assert_equal "The Queen", speech.person_override
    assert_equal attributes[:delivered_on], speech.delivered_on
    assert_equal attributes[:location], speech.location
  end

  test "update should save modified speech attributes" do
    speech = create(:speech)
    new_role_appointment = create(:role_appointment)
    new_delivered_on = speech.delivered_on + 1
    new_speech_type = SpeechType::Transcript

    put :update, id: speech.id, edition: controller_attributes_for_instance(speech,
      role_appointment_id: new_role_appointment.id,
      speech_type_id: new_speech_type.id,
      delivered_on: new_delivered_on,
      location: "new-location"
    )

    speech = Speech.last
    assert_equal new_speech_type, speech.speech_type
    assert_equal new_role_appointment, speech.role_appointment
    assert_equal new_delivered_on, speech.delivered_on
    assert_equal "new-location", speech.location
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:role_appointment, :speech_type).reverse_merge(
      role_appointment_id: create(:role_appointment).id,
      speech_type_id: SpeechType::Transcript
    )
  end
end
