require "test_helper"

class SpeechesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  # should_render_a_list_of :speeches, :first_published_at
  should_show_related_policies_for :speech
  should_show_the_world_locations_associated_with :speech
  should_display_inline_images_for :speech
  should_set_meta_description_for :speech
  should_set_the_article_id_for_the_edition_for :speech

  view_test "should display generic details about the speech" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May", image: fixture_file_upload('minister-of-funk.960x640.jpg'))
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: Time.zone.parse("2011-06-01 00:00:00"), location: "The Guidhall")

    get :show, id: published_speech.document

    assert_select ".meta a", "Theresa May" # \s* as \s* Secretary of State \s* in \s* Home Office/
    assert_select ".delivered-on", /1 June 2011/
    assert_select ".location", /The Guidhall/
  end

  view_test "should display who gave the speech even if they are not appointed to the same position anymore" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May", image: fixture_file_upload('minister-of-funk.960x640.jpg'))
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may, started_at: 1.year.ago, ended_at: 1.day.ago)
    subsequent_appointment = create(:role_appointment, role: home_secretary, started_at: 1.day.ago)
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: 6.months.ago, location: "The Guidhall")

    get :show, id: published_speech.document

    assert_select ".meta a", "Theresa May"
  end

  view_test "should display who gave the speech even if they are not a real person on IG" do
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type, delivered_on: 6.months.ago, location: "Buckingham palace", person_override: "The Queen")

    get :show, id: published_speech.document

    assert_select ".meta dd", "The Queen"
  end

  view_test "should display details about a transcript" do
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".explanation", "(Transcript of the speech, exactly as it was delivered)"
    assert_select ".type", "Speech"
  end

  view_test "should display details about a draft text" do
    speech_type = SpeechType::DraftText
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".explanation", "(Original script, may differ from delivered version)"
    assert_select ".type", "Speech"
  end

  view_test "should display details about speaking notes" do
    speech_type = SpeechType::SpeakingNotes
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".explanation", "(Speaker&#x27;s notes, may differ from delivered version)"
    assert_select ".type", "Speech"
  end

  view_test "should display details about a written statement" do
    speech_type = SpeechType::WrittenStatement
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    refute_select ".explanation"
    assert_select ".type", "Written statement to Parliament"
  end

  view_test "should display details about an oral statement" do
    speech_type = SpeechType::OralStatement
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    refute_select ".explanation"
    assert_select ".type", "Oral statement to Parliament"
  end

  view_test "should omit location if not given" do
    published_speech = create(:published_speech, location: '')

    get :show, id: published_speech.document
    refute_select ".location"
  end

  view_test "shoud set Google Analytics headers based on the organisation of the person who delivered the speech" do
    organisation = create(:organisation, acronym: "ABC")
    ministerial_role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:role_appointment, role: ministerial_role)
    speech = create(:published_speech, role_appointment: role_appointment)

    get :show, id: speech.document

    assert_equal "<#{organisation.analytics_identifier}>", response.headers["X-Slimmer-Organisations"]
    assert_equal organisation.acronym.downcase, response.headers["X-Slimmer-Page-Owner"]
  end
end
