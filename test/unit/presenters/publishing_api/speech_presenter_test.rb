require "test_helper"

class PublishingApi::SpeechPresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  def iso8601_regex
    /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}$/
  end

  setup do
    create(:government, name: "The Government", slug: "the-government")
  end

  let(:minister) { create(:ministerial_role) }
  let(:person) { create(:person, forename: "Tony") }

  let(:role_appointment) do
    create(:role_appointment, role: minister, person: person)
  end

  let(:speech) { create(:speech, role_appointment: role_appointment) }
  let(:presented) { PublishingApi::SpeechPresenter.new(speech) }

  describe "validating against content schemas" do
    it "is valid against the details schema" do
      assert_valid_against_schema(presented.content, "speech")
    end

    it "is valid against the links schema" do
      assert_valid_against_links_schema({ links: presented.links }, "speech")
    end
  end

  describe "base attributes and details" do
    let(:person) do
      create(:person,
              forename: "Tony",
              image: File.open(
                Rails.root.join("test", "fixtures", "images", "960x640_gif.gif")))
    end

    let(:speech) do
      create(:speech,
             title: "Speech title",
             summary: "The description",
             body: "# Woo!\nSome content",
             role_appointment: role_appointment)
    end

    let(:expected_body) do
      expected_body = <<-HTML.strip_heredoc
      <div class="govspeak"><h1 id="woo">Woo!</h1>
      <p>Some content</p>
      </div>
      HTML
      expected_body.chomp
    end

    it "contains the expected values" do
      assert_equal("Speech title",        presented.content[:title])
      assert_equal("The description",     presented.content[:description])
      assert_equal("whitehall",           presented.content[:publishing_app])
      assert_equal("government-frontend", presented.content[:rendering_app])

      details = presented.content[:details]
      refute(details[:political])
      assert_equal(expected_body,     details[:body])
      assert_match(iso8601_regex,     details[:delivered_on])
      assert_equal("Transcript of the speech, exactly as it was delivered", details[:speech_type_explanation])

      assert_equal("The Government",  details[:government][:title])
      assert_equal("the-government",  details[:government][:slug])
      assert_equal(true,              details[:government][:current])

      assert_equal("Tony",             details[:image][:alt_text])
      assert_match(/960x640_gif.gif$/, details[:image][:url])
    end
  end

  describe "links" do
    let(:policy_content_id) { SecureRandom.uuid }
    let(:topical_event) { create(:topical_event) }
    let(:world_location) { create(:world_location) }

    before do
      speech.add_policy(policy_content_id)
      speech.topical_events << topical_event
      speech.world_locations << world_location
    end

    it "contains the expected keys and values" do
      assert_includes(presented.links.keys, :organisations)
      assert_includes(presented.links.keys, :related_policies)
      assert_includes(presented.links.keys, :speaker)
      assert_includes(presented.links.keys, :topical_events)
      assert_includes(presented.links.keys, :people)
      assert_includes(presented.links.keys, :roles)
      assert_includes(presented.links.keys, :world_locations)

      assert_includes(presented.links[:organisations], speech.organisations.first.content_id)
      assert_includes(presented.links[:related_policies], policy_content_id)
      assert_includes(presented.links[:speaker], person.content_id)
      assert_includes(presented.links[:topical_events], topical_event.content_id)
      assert_includes(presented.links[:roles], speech.role_appointment.role.content_id)
      assert_includes(presented.links[:people], person.content_id)
      assert_includes(presented.links[:world_locations], world_location.content_id)
    end

    context "no role appointment (no speaker)" do
      before do
        speech.role_appointment = nil
      end

      it "doesn't present a speaker link" do
        refute(presented.links.has_key?(:speaker))
      end

      it "doesn't present a roles link" do
        refute(presented.links.has_key?(:roles))
      end

      it "doesn't present a people link" do
        refute(presented.links.has_key?(:people))
      end
    end
  end

  describe "speech types" do
    before do
      Speech.any_instance.stubs(:change_history).returns({})
      Speech.any_instance.stubs(:document).returns(document)
    end

    let(:document) { FactoryGirl.build(:document) }

    [SpeechType::DraftText, SpeechType::SpeakingNotes, SpeechType::Transcript].each do |speech_type|
      context "for #{speech_type.plural_name}" do
        let(:speech) { FactoryGirl.build(:speech, speech_type: speech_type) }
        it "is 'speech' for draft text" do
          assert_equal(presented.content[:document_type], "speech")
        end
      end
    end

    [SpeechType::AuthoredArticle, SpeechType::OralStatement, SpeechType::WrittenStatement].each do |speech_type|
      context "for #{speech_type.plural_name}" do
        let(:speech) { FactoryGirl.build(:speech, speech_type: speech_type) }
        it "is '#{speech_type.key}'" do
          assert_equal(presented.content[:document_type], speech_type.key)
        end
      end
    end
  end

  describe "image" do
    let(:person) do
      create(
        :person,
        forename: "Tony",
        image: File.open(
          Rails.root.join("test", "fixtures", "images", "960x640_gif.gif"))
      )
    end

    let(:speech) do
      create(
        :speech,
        title: "Speech title",
        summary: "The description",
        body: "# Woo!\nSome content",
        role_appointment: role_appointment
      )
    end


    context "with featured image" do
      let!(:feature) do
        create(
          :feature,
          document: speech.document,
          image: File.open(
            Rails.root.join("test", "fixtures", "images", "960x640_gif.gif")
          ),
          alt_text: "featured image"
        )
      end

      it "presents the featured image" do
        details = presented.content[:details]
        assert_equal("featured image", details[:image][:alt_text])
        assert_match(/960x640_gif.gif$/, details[:image][:url])
      end
    end

    context "with speaker with image" do
      it "presents the speaker image" do
        details = presented.content[:details]
        assert_equal("Tony", details[:image][:alt_text])
        assert_match(/960x640_gif.gif$/, details[:image][:url])
      end
    end
  end
end
