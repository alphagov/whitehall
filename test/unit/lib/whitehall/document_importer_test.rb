require "test_helper"

module Whitehall
  class DocumentImporterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @user = create(:user, email: "baz@gov.uk")
      @primary_org = create(:organisation)
      @secondary_org = create(:organisation)
      @role_appointment = create(:role_appointment)
      @topical_event = create(:topical_event)
      @world_location = create(:world_location)
      @government = create(:government)
      @data = {
        "created_by" => @user.email,
        "created_at" => 2.days.ago.iso8601,
        "first_published_at" => 2.days.ago.iso8601,
        "content_id" => "a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6",
        "state" => "published",
        "document_type" => "news_story",
        "title" => "Imported title",
        "base_path" => "/government/news/imported-title",
        "summary" => "Imported summary",
        "body" => "Imported body",
        "political" => true,
        "government_id" => @government.content_id,
        "tags" => {
          "primary_publishing_organisation" => [@primary_org.content_id],
          "organisations" => [@secondary_org.content_id],
          "role_appointments" => [@role_appointment.content_id],
          "topical_events" => [@topical_event.content_id],
          "world_locations" => [@world_location.content_id],
        },
        "change_notes" => [
          {
            "note" => "First published.",
            "public_timestamp" => 2.days.ago.iso8601,
          },
        ],
      }
    end

    describe ".import!" do
      it "creates an edition via `create_base_edition!` and updates the corresponding Document" do
        @stubbed_edition = create(:draft_standard_edition, configurable_document_type: "news_story", block_content: { "body" => "foo" })
        Whitehall::DocumentImporter.expects(:create_base_edition!).with { |data|
          assert_equal data, @data
        }.returns(@stubbed_edition)
        Whitehall::DocumentImporter.import!(@data)
        document = @stubbed_edition.document
        assert_equal "a1b2c3d4-e5f6-7a8b-9c0d-e1f2a3b4c5d6", document.content_id
        assert_equal "imported-title", document.slug
        assert_equal Time.zone.parse(2.days.ago.iso8601).to_i, @stubbed_edition.most_recent_version.created_at.to_i
        assert_equal Time.zone.parse(2.days.ago.iso8601).to_i, document.created_at.to_i
      end
    end

    describe ".create_base_edition!" do
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

      it "allows government to be nil" do
        data = @data.merge({
          "government_id" => nil,
        })
        edition = Whitehall::DocumentImporter.create_base_edition!(data)
        assert_nil edition.government_id
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

    describe ".set_publishing_metadata" do
      it "sets the correct timestamps and boolean for a published document" do
        edition = build(:draft_standard_edition, configurable_document_type: "news_story")
        data = @data.merge({
          "state" => "published",
          "created_at" => 2.days.ago.iso8601,
          "first_published_at" => 2.days.ago.iso8601,
          "change_notes" => [
            {
              "note" => "Subsequently published.",
              "public_timestamp" => 1.day.ago.iso8601,
            },
            {
              "note" => "First published.",
              "public_timestamp" => 2.days.ago.iso8601,
            },
          ],
        })
        Whitehall::DocumentImporter.set_publishing_metadata(edition, data)
        assert_equal 2.days.ago.to_i, edition.first_published_at.to_i
        assert_equal 1.day.ago.to_i, edition.major_change_published_at.to_i
        assert_not edition.previously_published
        assert_equal 2, edition.published_major_version
        assert_equal 2.days.ago.to_i, edition.created_at.to_i
      end

      it "sets the correct timestamps and boolean for a published document where created_at is after first_published_at" do
        edition = build(:draft_standard_edition)
        data = @data.merge({
          "state" => "published",
          "created_at" => 1.day.ago.iso8601,
          "first_published_at" => 2.days.ago.iso8601,
          "change_notes" => [
            {
              "note" => "First published.",
              "public_timestamp" => 2.days.ago.iso8601,
            },
          ],
        })
        Whitehall::DocumentImporter.set_publishing_metadata(edition, data)
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
  end
end
