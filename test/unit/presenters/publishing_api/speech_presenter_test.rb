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
             body: "Some content",
             role_appointment: role_appointment)
    end

    it "contains the expected values" do
      assert_equal("Speech title",        presented.content[:title])
      assert_equal("The description",     presented.content[:description])
      assert_equal("whitehall",           presented.content[:publishing_app])
      assert_equal("whitehall-frontend",  presented.content[:rendering_app])

      details = presented.content[:details]
      refute(details[:political])
      assert_equal("Some content",    details[:body])
      assert_match(iso8601_regex,     details[:delivered_on])

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

    before do
      speech.add_policy(policy_content_id)
      speech.topical_events << topical_event
    end

    it "contains the expected keys and values" do
      assert_includes(presented.links.keys, :organisations)
      assert_includes(presented.links.keys, :policies)
      assert_includes(presented.links.keys, :speaker)
      assert_includes(presented.links.keys, :topical_events)

      assert_includes(presented.links[:organisations], speech.organisations.first.content_id)
      assert_includes(presented.links[:policies], policy_content_id)
      assert_includes(presented.links[:speaker], person.content_id)
      assert_includes(presented.links[:topical_events], topical_event.content_id)
    end

    context "no role appointment (no speaker)" do
      before do
        speech.role_appointment = nil
      end

      it "doesn't present a speaker link" do
        refute(presented.links.has_key?(:speaker))
      end
    end
  end
end
