require 'test_helper'

module Whitehall::Uploader
  class SpeechRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
      @default_organisation = stub('Organisation')
      @logged = StringIO.new
      @logger = Logger.new(@logged)
    end

    def new_speech_row(data = {})
      Whitehall::Uploader::SpeechRow.new(data, 1, @attachment_cache, @default_organisation, @logger)
    end

    def basic_headings
      %w{old_url title summary body  type  delivered_by  delivered_on event_and_location  policy_1  policy_2  policy_3  policy_4  organisation country_1 country_2 country_3 country_4}
    end

    test "validates row headings" do
      assert_equal [], Whitehall::Uploader::SpeechRow.heading_validation_errors(basic_headings)
    end

    test "validation reports missing row headings" do
      keys = basic_headings - ['title']
      assert_equal ["missing fields: 'title'"], Whitehall::Uploader::SpeechRow.heading_validation_errors(keys)
    end

    test "validation reports extra row headings" do
      keys = basic_headings + ['extra_stuff']
      assert_equal ["unexpected fields: 'extra_stuff'"], Whitehall::Uploader::SpeechRow.heading_validation_errors(keys)
    end

    test "takes legacy urls from the old_url column" do
      row = new_speech_row({"old_url" => "http://example.com/old-url"})
      assert_equal ["http://example.com/old-url"], row.legacy_urls
    end

    test "takes title from the title column" do
      row = new_speech_row({"title" => "a-title"})
      assert_equal "a-title", row.title
    end

    test "takes body from the body column" do
      row = new_speech_row({"body" => "Some body goes here"})
      assert_equal "Some body goes here", row.body
    end

    test "takes summary from the summary column" do
      row = new_speech_row({"summary" => "a-summary"})
      assert_equal "a-summary", row.summary
    end

    test 'if summary column is blank, generates summary from body' do
      row = new_speech_row("summary" => '', "body" => 'woo')
      Parsers::SummariseBody.stubs(:parse).with('woo').returns('w')
      assert_equal 'w', row.summary
    end

    test "finds temporary organisation from the organisation field" do
      organisation = stub('Organisation', name: 'Treasury')
      Organisation.stubs(:find_by_name).with('Treasury').returns(organisation)

      row = new_speech_row({"organisation" => "Treasury"})
      assert_equal [organisation], row.organisations
    end

    test "uses default organisation as temporary org if the organisation field is blank" do
      row = new_speech_row({"organisation" => ""})
      assert_equal [@default_organisation], row.organisations
    end

    test "finds speech type by slug in the speech type column" do
      row = new_speech_row({"type" => "transcript"})
      assert_equal SpeechType::Transcript, row.speech_type
    end

    test "finds role appointment for person who delivered speech based on delivered_by column and delivered_on date" do
      minister = create(:person)
      role = create(:ministerial_role)
      role_appointment_1 = create(:role_appointment, role: role, person: minister, started_at: Date.parse('14-May-2009'), ended_at: Date.parse('20-Oct-2009'))
      role_appointment_2 = create(:role_appointment, role: role, person: minister, started_at: Date.parse('21-Oct-2009'))
      row = new_speech_row({ "delivered_by" => minister.slug, "delivered_on" => "16-May-2009" })
      assert_equal role_appointment_1, row.role_appointment
    end

    test "leaves role appointment blank if delivered on is blank" do
      minister = create(:person)
      role = create(:ministerial_role)
      role_appointment_1 = create(:role_appointment, role: role, person: minister, started_at: Date.parse('14-May-2009'), ended_at: Date.parse('20-Oct-2009'))
      role_appointment_2 = create(:role_appointment, role: role, person: minister, started_at: Date.parse('21-Oct-2009'))
      row = new_speech_row({ "delivered_by" => minister.slug, "delivered_on" => '' })
      assert_nil row.role_appointment
    end

    test "warns about discarded delivered_by information if delivered on is blank" do
      minister = create(:person, forename: 'Brian', surname: 'Jones')
      row = new_speech_row({ "delivered_by" => minister.slug, "delivered_on" => '' })
      row.role_appointment
      assert_match /Discarding delivered_by information "brian-jones" because delivered_on is missing/, @logged.string
    end

    test "finds up to 4 policies specified by slug in columns policy_1, policy_2, policy_3 and policy_4" do
      policy_1 = create(:published_policy, title: "Policy 1")
      policy_2 = create(:published_policy, title: "Policy 2")
      policy_3 = create(:published_policy, title: "Policy 3")
      policy_4 = create(:published_policy, title: "Policy 4")
      row = new_speech_row({"policy_1" => policy_1.slug,
        "policy_2" => policy_2.slug,
        "policy_3" => policy_3.slug,
        "policy_4" => policy_4.slug
      })

      assert_equal [policy_1, policy_2, policy_3, policy_4], row.related_policies
    end

    test "takes location from the event_and_location column" do
      row = new_speech_row({"event_and_location" => "a-location"})
      assert_equal "a-location", row.location
    end

    test "parses the delivered_on date from the delivered_on column" do
      row = new_speech_row({"delivered_on" => "16-May-2012"})
      assert_equal Date.parse("2012-05-16"), row.delivered_on
    end

    test "takes the first_published_at date from the delivered_on column" do
      row = new_speech_row({"delivered_on" => "16-May-2012"})
      assert_equal Date.parse("2012-05-16"), row.first_published_at
    end

    test "leaves the delivered_on blank if the delivered_on column is blank" do
      row = new_speech_row({"delivered_on" => ''})
      assert_nil row.delivered_on
    end

    test "leaves the first_published_at blank if the delivered_on column is blank" do
      row = new_speech_row({"delivered_on" => ''})
      assert_nil row.first_published_at
    end

    test "finds related world locations using the world location finder" do
      world_locations = 5.times.map { stub('world_location') }
      Whitehall::Uploader::Finders::WorldLocationsFinder.stubs(:find).with("first", "second", "third", "fourth", anything, anything).returns(world_locations)
      row = new_speech_row({
          "country_1" => "first",
          "country_2" => "second",
          "country_3" => "third",
          "country_4" => "fourth"
        })
      assert_equal world_locations, row.world_locations
    end
  end
end
