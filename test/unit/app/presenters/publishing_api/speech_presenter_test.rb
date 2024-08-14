require "test_helper"

class PublishingApi::SpeechPresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe PublishingApi::SpeechPresenter do
    def iso8601_regex
      /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}$/
    end

    setup do
      @current_government = create(:government, name: "The Government", slug: "the-government")
    end

    let(:minister) { create(:ministerial_role) }
    let(:person) { create(:person, forename: "Tony") }

    let(:role_appointment) do
      create(:role_appointment, role: minister, person:)
    end

    let(:speech) { create(:speech, role_appointment:) }
    let(:presented) { PublishingApi::SpeechPresenter.new(speech) }

    describe "validating against content schemas" do
      it "is valid against the details schema" do
        assert_valid_against_publisher_schema(presented.content, "speech")
      end

      it "is valid against the links schema" do
        assert_valid_against_links_schema({ links: presented.links }, "speech")
      end
    end

    describe "base attributes and details" do
      let(:person) do
        create(
          :person,
          :with_image,
          forename: "Tony",
        )
      end

      let(:speech) do
        create(
          :speech,
          title: "Speech title",
          summary: "The description",
          body: "# Woo!\nSome content",
          role_appointment:,
          location: "A location",
          government: @current_government,
        )
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
        assert_equal("Speech title", presented.content[:title])
        assert_equal("The description", presented.content[:description])
        assert_equal(Whitehall::PublishingApp::WHITEHALL, presented.content[:publishing_app])
        assert_equal("government-frontend", presented.content[:rendering_app])
        assert_equal([speech.auth_bypass_id], presented.content[:auth_bypass_ids])

        details = presented.content[:details]
        assert(details[:political])
        assert_equal(expected_body, details[:body])
        assert_match(iso8601_regex, details[:delivered_on])
        assert_match("A location", details[:location])
        assert_equal("Transcript of the speech, exactly as it was delivered", details[:speech_type_explanation])

        assert_equal("Tony", details[:image][:alt_text])
        assert_match(/minister-of-funk.960x640.jpg$/, details[:image][:url])
      end
    end

    describe "change_history" do
      it "is generated for a published speech" do
        assert_equal(
          1,
          PublishingApi::SpeechPresenter
            .new(create(:published_speech))
            .content[:details][:change_history]
            .length,
        )
      end
    end

    describe "links" do
      let(:policy_content_id) { SecureRandom.uuid }
      let(:topical_event) { create(:topical_event) }
      let(:world_location) { create(:world_location) }

      before do
        speech.topical_events << topical_event
        speech.world_locations << world_location
      end

      it "contains the expected keys and values" do
        assert_includes(presented.links.keys, :organisations)
        assert_includes(presented.links.keys, :speaker)
        assert_includes(presented.links.keys, :topical_events)
        assert_includes(presented.links.keys, :people)
        assert_includes(presented.links.keys, :roles)
        assert_includes(presented.links.keys, :world_locations)
        assert_includes(presented.links.keys, :government)

        assert_includes(presented.links[:organisations], speech.organisations.first.content_id)
        assert_includes(presented.links[:speaker], person.content_id)
        assert_includes(presented.links[:topical_events], topical_event.content_id)
        assert_includes(presented.links[:roles], speech.role_appointment.role.content_id)
        assert_includes(presented.links[:people], person.content_id)
        assert_includes(presented.links[:world_locations], world_location.content_id)
        assert_includes(presented.links[:government], @current_government.content_id)
      end

      context "no role appointment (no speaker)" do
        before do
          speech.role_appointment = nil
        end

        it "doesn't present a speaker link" do
          assert_not(presented.links.key?(:speaker))
        end

        it "presents an empty roles link" do
          assert_empty(presented.links[:roles])
        end

        it "presents an empty people link" do
          assert_empty(presented.links[:people])
        end
      end

      context "speaker without profile" do
        before do
          speech.role_appointment = nil
          speech.person_override = "A custom speaker"
        end

        it "doesn't present a speaker link" do
          assert_not(presented.links.key?(:speaker))
        end

        it "includes the custom speaker as speaker_without_profile" do
          assert("A custom speaker", presented.content.dig(:details, :speaker_without_profile))
        end
      end

      context "speech without location" do
        before do
          speech.location = ""
        end

        it "doesn't present a speech location" do
          assert_nil presented.content.dig(:details, :location)
        end
      end
    end

    describe "speech types" do
      before do
        Speech.any_instance.stubs(:change_history).returns({})
        Speech.any_instance.stubs(:document).returns(document)
      end

      let(:document) { FactoryBot.build(:document) }

      [SpeechType::DraftText, SpeechType::SpeakingNotes, SpeechType::Transcript].each do |speech_type|
        context "for #{speech_type.plural_name}" do
          let(:speech) { FactoryBot.build(:speech, speech_type:) }
          it "is 'speech' for draft text" do
            assert_equal(presented.content[:document_type], "speech")
          end
        end
      end

      [SpeechType::AuthoredArticle, SpeechType::OralStatement, SpeechType::WrittenStatement].each do |speech_type|
        context "for #{speech_type.plural_name}" do
          let(:speech) { FactoryBot.build(:speech, speech_type:) }
          it "is '#{speech_type.key}'" do
            assert_equal(presented.content[:document_type], speech_type.key)
          end
        end
      end
    end

    describe "image" do
      let(:person) { create(:person, :with_image, forename: "Tony") }

      let(:speech) do
        create(
          :speech,
          title: "Speech title",
          summary: "The description",
          body: "# Woo!\nSome content",
          role_appointment:,
        )
      end

      context "with featured image" do
        let!(:feature) do
          create(
            :feature,
            document: speech.document,
            image: build(:featured_image_data),
            alt_text: "featured image",
          )
        end

        let!(:feature_two) do
          create(
            :feature,
            document: speech.document,
            image: build(:featured_image_data, file: upload_fixture("big-cheese.960x640.jpg", "image/jpg")),
            alt_text: "featured image two",
          )
        end

        it "presents the most recent featured image" do
          details = presented.content[:details]
          assert_equal("featured image two", details[:image][:alt_text])
          assert_match(/big-cheese.960x640.jpg$/, details[:image][:url])
        end

        it "does not present the featured image if any assets are missing" do
          feature_two.image.assets.destroy_all

          details = presented.content[:details]

          assert_nil details[:image]
        end
      end

      context "with speaker with image" do
        it "presents the speaker image" do
          details = presented.content[:details]
          assert_equal("Tony", details[:image][:alt_text])
          assert_match(/minister-of-funk.960x640.jpg$/, details[:image][:url])
        end

        test "does not present the person image if it has missing assets" do
          person.image.assets.destroy_all

          details = presented.content[:details]

          assert_nil details[:image]
        end
      end
    end
  end
end
