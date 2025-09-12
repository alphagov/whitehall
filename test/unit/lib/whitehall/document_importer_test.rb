require "test_helper"

module Whitehall
  class DocumentImporterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    describe ".create_base_edition!" do
      setup do
        @user = create(:user, email: "baz@gov.uk")
        @primary_org = create(:organisation)
        @secondary_org = create(:organisation)
        @government = create(:government)
        @role_appointment = create(:role_appointment)
        @topical_event = create(:topical_event)
        @world_location = create(:world_location)
        @data = {
          "created_by" => @user.email,
          "created_at" => 2.days.ago.iso8601,
          "first_published_at" => 2.days.ago.iso8601,
          "state" => "published",
          "document_type" => "news_story",
          "title" => "Imported title",
          "summary" => "Imported summary",
          "body" => "Imported body",
          "political" => true,
          "government_id" => @government.id,
          "tags" => {
            "primary_publishing_organisation" => @primary_org.content_id,
            "organisations" => [@secondary_org.content_id],
            "role_appointments" => [@role_appointment.content_id],
            "topical_events" => [@topical_event.content_id],
            "world_locations" => [@world_location.content_id],
          },
          "change_notes" => [],
        }
      end

      it "creates a StandardEdition with the correct attributes" do
        edition = Whitehall::DocumentImporter.create_base_edition!(@data)
        assert_equal "published", edition.state
        assert_equal @user, edition.creator
        assert_equal "news_story", edition.configurable_document_type
        assert_equal "Imported title", edition.title
        assert_equal "Imported summary", edition.summary
        assert_equal "Imported body", edition.block_content["body"]
        assert_equal true, edition.political
        assert_equal @government.id, edition.government_id
        assert_equal @primary_org.id, edition.alternative_format_provider_id
      end

      it "acts as the robot user if the creator cannot be found" do
        robot_user = User.create!(name: "Scheduled Publishing Robot", email: "robot@example.com")
        data = @data.merge({
          "created_by" => "someone-who-does-not-exist-in-whitehall@example.com",
        })
        edition = Whitehall::DocumentImporter.create_base_edition!(data)
        assert_equal robot_user, edition.creator
      end
    end

    describe ".robot_user" do
      it "retrieves the robot user" do
        robot_user = User.create!(name: "Scheduled Publishing Robot", email: "robot@example.com")
        assert_equal robot_user, Whitehall::DocumentImporter.robot_user
      end
    end

    describe ".set_publish_timestamps" do
      it "sets the correct timestamps for a published document" do
        edition = build(:draft_standard_edition)
        data = {
          "state" => "published",
          "created_at" => 2.days.ago.iso8601,
          "first_published_at" => 2.days.ago.iso8601,
        }
        Whitehall::DocumentImporter.set_publish_timestamps(edition, data)
        assert_nil edition.first_published_at
        assert_equal 2.days.ago.to_i, edition.major_change_published_at.to_i
        assert_not edition.previously_published
      end

      it "sets the correct timestamps for a published document where created_at is after first_published_at" do
        edition = build(:draft_standard_edition)
        data = {
          "state" => "published",
          "created_at" => 1.day.ago.iso8601,
          "first_published_at" => 2.days.ago.iso8601,
        }
        Whitehall::DocumentImporter.set_publish_timestamps(edition, data)
        assert_equal 2.days.ago.to_i, edition.first_published_at.to_i
        assert_equal 2.days.ago.to_i, edition.major_change_published_at.to_i
        assert edition.previously_published
      end
    end

    describe ".derived_state" do
      it "returns 'published' for 'published' and 'published_but_needs_2i'" do
        assert_equal "published", Whitehall::DocumentImporter.derived_state("published")
        assert_equal "published", Whitehall::DocumentImporter.derived_state("published_but_needs_2i")
      end

      it "returns 'withdrawn' for 'withdrawn'" do
        assert_equal "withdrawn", Whitehall::DocumentImporter.derived_state("withdrawn")
      end

      it "raises for unsupported states" do
        assert_raises(RuntimeError) { Whitehall::DocumentImporter.derived_state("draft") }
        assert_raises(RuntimeError) { Whitehall::DocumentImporter.derived_state("archived") }
        assert_raises(RuntimeError) { Whitehall::DocumentImporter.derived_state("supercalifragilistic") }
      end
    end

    describe ".pre_process_body" do
      it "replaces Contact content IDs with Whitehall Contact IDs" do
        contact = create(:contact, content_id: "c1f13fd8-9feb-4028-9323-7cb3383323b4")
        body_input = <<~BODY
          ## Foo

          Bar

          [Contact: #{contact.content_id}]
        BODY
        expected_body_output = <<~BODY
          ## Foo

          Bar

          [Contact:#{contact.id}]
        BODY

        body_output = Whitehall::DocumentImporter.pre_process_body(body_input)

        assert_equal expected_body_output, body_output
      end
    end
  end
end
