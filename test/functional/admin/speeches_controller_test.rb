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
  should_allow_assignment_to_document_series :speech
  should_allow_scheduled_publication_of :speech
  should_allow_access_limiting_of :speech
  should_allow_association_with_topical_events :speech

  view_test "new displays speech fields" do
    get :new

    assert_select "form#edition_new" do
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

  view_test "should display details about the speech" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May")
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may, started_at: Date.parse('2011-01-01'))
    speech_type = SpeechType::Transcript
    draft_speech = create(:draft_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: Time.zone.parse("2011-06-01 00:00:00"), location: "The Guidhall")

    get :show, id: draft_speech

    assert_select ".details" do
      assert_select ".type", "Transcript"
      assert_select ".role_appointment" do
        assert_select ".person", "Theresa May"
        assert_select ".role", "Secretary of State"
        assert_select ".organisations", "Home Office"
      end
      assert_select ".delivered_on", "1 June 2011 00:00"
      assert_select ".location", "The Guidhall"
    end
  end

  view_test "should display details about the speech when delivered by a person who isn't in IG" do
    home_office = create(:organisation, name: "Home Office")
    speech_type = SpeechType::Transcript
    draft_speech = create(:draft_speech, speech_type: speech_type, person_override: "The Queen", delivered_on: Time.zone.parse("2011-06-01 00:00:00"), location: "The Guidhall", organisations: [home_office], role_appointment: nil)

    get :show, id: draft_speech

    assert_select ".details" do
      assert_select ".type", "Transcript"
      assert_select ".person", "The Queen"
      assert_select ".organisations", "Home Office"
      assert_select ".delivered_on", "1 June 2011 00:00"
      assert_select ".location", "The Guidhall"
    end
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:role_appointment, :speech_type).reverse_merge(
      role_appointment_id: create(:role_appointment).id,
      speech_type_id: SpeechType::Transcript
    )
  end
end
