require "test_helper"

class SpeechesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_render_a_list_of :speeches, :first_published_at
  should_show_related_policies_and_topics_for :speech
  should_show_the_countries_associated_with :speech
  should_display_inline_images_for :speech
  should_not_display_lead_image_for :speech
  should_show_change_notes :speech

  test "should display generic details about the speech" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May", image: fixture_file_upload('minister-of-funk.jpg'))
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall")

    get :show, id: published_speech.document

    assert_select ".details .role_appointment .person", "Theresa May" # \s* as \s* Secretary of State \s* in \s* Home Office/
    assert_select ".details .delivered_on", /1 June 2011/
    assert_select ".details .location", /The Guidhall/
  end

  test "should display who gave the speech even if they are not appointed to the same position anymore" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, forename: "Theresa", surname: "May", image: fixture_file_upload('minister-of-funk.jpg'))
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may, started_at: 1.year.ago, ended_at: 1.day.ago)
    subsequent_appointment = create(:role_appointment, role: home_secretary, started_at: 1.day.ago)
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: 6.months.ago, location: "The Guidhall")

    get :show, id: published_speech.document

    assert_select ".details .role_appointment .person", "Theresa May"
  end

  test "should display details about a transcript" do
    speech_type = SpeechType::Transcript
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".details" do
      assert_select ".explanation",
        "This is a transcript of the speech, exactly as it was delivered."
    end
    assert_select ".page_header .label", "Speech"
  end

  test "should display details about a draft text" do
    speech_type = SpeechType::DraftText
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".details" do
      assert_select ".explanation",
        "This is the text of the speech as drafted, which may differ slightly from the delivered version."
    end
    assert_select ".page_header .label", "Speech"
  end

  test "should display details about speaking notes" do
    speech_type = SpeechType::SpeakingNotes
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".details" do
      assert_select ".explanation",
        "These are the speaker's notes, not a transcript of the speech as it was delivered."
    end
    assert_select ".page_header .label", "Speech"
  end

  test "should display details about a written statement" do
    speech_type = SpeechType::WrittenStatement
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".details" do
      refute_select ".explanation"
    end
    assert_select ".page_header .label", "Written statement"
  end

  test "should display details about an oral statement" do
    speech_type = SpeechType::OralStatement
    published_speech = create(:published_speech, speech_type: speech_type)

    get :show, id: published_speech.document
    assert_select ".details" do
      refute_select ".explanation"
    end
    assert_select ".page_header .label", "Oral statement"
  end

  test "should omit location if not given" do
    published_speech = create(:published_speech, location: nil)

    get :show, id: published_speech.document
    assert_select ".details" do
      refute_select ".location"
    end
  end
end
