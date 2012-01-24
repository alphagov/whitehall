require 'test_helper'

class Admin::SpeechesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :speech
  should_allow_creating_of :speech
  should_allow_editing_of :speech

  should_allow_association_between_countries_and :speech
  should_be_rejectable :speech
  should_be_force_publishable :speech
  should_be_able_to_delete_a_document :speech
  should_link_to_public_version_when_published :speech
  should_not_link_to_public_version_when_not_published :speech
  should_prevent_modification_of_unmodifiable :speech
  should_allow_overriding_of_first_published_at_for :speech

  test "new displays speech fields" do
    get :new

    assert_select "form#document_new" do
      assert_select "select[name='document[speech_type_id]']"
      assert_select "select[name='document[role_appointment_id]']"
      assert_select "select[name*='document[delivered_on']", count: 3
      assert_select "input[name='document[location]'][type='text']"
    end
  end

  test "create should create a new speech" do
    role_appointment = create(:role_appointment)
    speech_type = create(:speech_type)
    attributes = controller_attributes_for(:speech, speech_type: speech_type, role_appointment: role_appointment)

    post :create, document: attributes

    assert speech = Speech.last
    assert_equal speech_type, speech.speech_type
    assert_equal role_appointment, speech.role_appointment
    assert_equal attributes[:delivered_on], speech.delivered_on
    assert_equal attributes[:location], speech.location
  end

  test "update should save modified speech attributes" do
    speech = create(:speech)
    new_role_appointment = create(:role_appointment)
    new_delivered_on = speech.delivered_on + 1
    new_speech_type = create(:speech_type)

    put :update, id: speech.id, document: {
      role_appointment_id: new_role_appointment.id,
      speech_type_id: new_speech_type.id,
      delivered_on: new_delivered_on,
      location: "new-location"
    }

    speech = Speech.last
    assert_equal new_speech_type, speech.speech_type
    assert_equal new_role_appointment, speech.role_appointment
    assert_equal new_delivered_on, speech.delivered_on
    assert_equal "new-location", speech.location
  end

  test "should display details about the speech" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May")
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    speech_type = create(:speech_type, name: "Transcript")
    draft_speech = create(:draft_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall")

    get :show, id: draft_speech

    assert_select ".details .type", "Transcript"
    assert_select ".details .ministerial_role", "Theresa May (Secretary of State, Home Office)"
    assert_select ".details .delivered_on", "June 1st, 2011"
    assert_select ".details .location", "The Guidhall"
  end

  test 'show displays related policies' do
    policy = create(:policy)
    speech = create(:speech, related_policies: [policy])
    get :show, id: speech
    assert_select_object policy
  end

  private

  def controller_attributes_for(document_type, attributes = {})
    role_appointment = attributes.delete(:role_appointment) || create(:role_appointment)
    speech_type = attributes.delete(:speech_type) || create(:speech_type)
    attributes_for(document_type, attributes.merge(
      role_appointment_id: role_appointment.id,
      speech_type_id: speech_type.id
    ))
  end
end
