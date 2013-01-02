require 'test_helper'

class Admin::SpeechesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :speech
  should_allow_creating_of :speech
  should_allow_editing_of :speech
  should_allow_revision_of :speech

  should_show_document_audit_trail_for :speech, :show
  should_show_document_audit_trail_for :speech, :edit

  should_allow_related_policies_for :speech
  should_allow_association_between_world_locations_and :speech
  should_allow_attached_images_for :speech
  should_be_rejectable :speech
  should_be_publishable :speech
  should_allow_unpublishing_for :speech
  should_be_force_publishable :speech
  should_be_able_to_delete_an_edition :speech
  should_link_to_public_version_when_published :speech
  should_not_link_to_public_version_when_not_published :speech
  should_link_to_preview_version_when_not_published :speech
  should_prevent_modification_of_unmodifiable :speech
  should_allow_overriding_of_first_published_at_for :speech
  should_allow_scheduled_publication_of :speech

  test "new displays speech fields" do
    get :new

    assert_select "form#edition_new" do
      assert_select "select[name='edition[speech_type_id]']"
      assert_select "select[name='edition[role_appointment_id]']"
      assert_select "select[name*='edition[delivered_on']", count: 3
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

  test "should display details about the speech" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May")
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may, started_at: Date.parse('2011-01-01'))
    speech_type = SpeechType::Transcript
    draft_speech = create(:draft_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall")

    get :show, id: draft_speech

    assert_select ".details" do
      assert_select ".type", "Transcript"
      assert_select ".role_appointment" do
        assert_select ".person", "Theresa May"
        assert_select ".role", "Secretary of State"
        assert_select ".organisations", "Home Office"
      end
      assert_select ".delivered_on", "1 June 2011"
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
