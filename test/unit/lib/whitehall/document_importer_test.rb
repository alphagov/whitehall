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

    describe ".combined_change_notes" do
      it "returns nil if there are no change notes" do
        assert_nil Whitehall::DocumentImporter.combined_change_notes([])
      end

      it "combines change notes into a single string" do
        change_notes = [
          { "public_timestamp" => 2.days.ago.iso8601, "note" => "First note" },
          { "public_timestamp" => 1.day.ago.iso8601, "note" => "Second note" },
        ]
        expected_output = "#{2.days.ago.strftime('%-d %B %Y')}: First note; #{1.day.ago.strftime('%-d %B %Y')}: Second note"
        assert_equal expected_output, Whitehall::DocumentImporter.combined_change_notes(change_notes)
      end
    end

    describe ".internal_history_summary" do
      it "returns nil if there is no internal history" do
        assert_equal "No internal history available", Whitehall::DocumentImporter.internal_history_summary([])
      end

      it "returns the internal history summary with the correct timestamp" do
        internal_history = [
          {
            "edition_number" => 3,
            "entry_type" => "approved",
            "date" => "25 May 2022",
            "time" => "10:24am",
            "user" => "foo.bar@gov.uk",
            "entry_content" => nil,
          },
          {
            "edition_number" => 3,
            "entry_type" => "internal_note",
            "date" => "20 May 2022",
            "time" => "11:50pm",
            "user" => "baz@gov.uk",
            "entry_content" => "Removed typo.",
          },
        ]

        Timecop.freeze(Time.zone.parse("2024-06-10 14:30")) do
          expected_output = <<~OUTPUT
            Imported from Content Publisher on 10 June 2024 at 14:30. Document history:<br><br>
            • 25 May 2022 10:24am: Approved by foo.bar@gov.uk<br>
            • 20 May 2022 11:50pm: Internal note by baz@gov.uk. Details: Removed typo.
          OUTPUT
          assert_equal expected_output.gsub("\n", ""), Whitehall::DocumentImporter.internal_history_summary(internal_history)
        end
      end
    end

    describe ".save_attachments" do
      setup do
        # Minimal stub of a callback, otherwise the `skip_callback` call raises exception.
        AttachmentData.set_callback(:save, :before, :update_file_attributes)
      end

      it "saves attachments to the edition" do
        edition = create(:edition)
        data = {
          "attachments" => [
            {
              "file_url" => "https://assets.publishing.service.gov.uk/media/628df069e90e071f6af1465d/foo.pdf",
              "title" => "foo",
              "created_at" => "2022-05-25 10:01:29 +0100",
            },
            {
              "file_url" => "https://assets.publishing.service.gov.uk/media/628df082e90e071f61322253/bar.csv",
              "title" => "bar",
              "created_at" => "2022-05-25 10:01:53 +0100",
            },
          ],
        }

        stub_request(:get, "https://assets.publishing.service.gov.uk/media/628df069e90e071f6af1465d/foo.pdf")
          .to_return(status: 200, body: "", headers: {})
        stub_request(:get, "https://assets.publishing.service.gov.uk/media/628df082e90e071f61322253/bar.csv")
          .to_return(status: 200, body: "", headers: {})

        Whitehall::DocumentImporter.save_attachments(data, edition)

        assert_equal 2, edition.attachments.count
        assert_equal "foo", edition.attachments.first.title
        assert_equal "bar", edition.attachments.last.title
      end

      it "populates attachment data from the URI response" do
        # Setup
        edition = create(:edition)
        file_url = "http://asset-manager.dev.gov.uk/media/1234-5678-9012-3456-7890/file.pdf"
        data = {
          "attachments" => [
            {
              "title" => "Attachment",
              "file_url" => file_url,
              "created_at" => 2.days.ago.iso8601,
            },
          ],
        }
        response = mock
        response.stubs(:content_type).returns("application/pdf")
        response.stubs(:size).returns(12_344_555)
        URI.stubs(:parse).with(file_url).returns(stub(open: response))
        PDF::Reader.stubs(:new).returns(stub(page_count: 1))

        # Action
        Whitehall::DocumentImporter.save_attachments(data, edition)

        # Assertions
        assert_equal 1, edition.attachments.count
        attachment = edition.attachments.find_by(title: "Attachment")
        assert_not_nil attachment
        assert_equal "application/pdf", attachment.attachment_data.content_type
        assert_equal 12_344_555, attachment.attachment_data.file_size
        assert_equal 1, attachment.attachment_data.number_of_pages
        assert_equal 2.days.ago.to_i, attachment.attachment_data.created_at.to_i
      end
    end

    describe ".save_images" do
      setup do
        @edition = create(:standard_edition, :with_organisations, configurable_document_type: "news_story")
        @asset_manager_id_for_original_asset = "3333f0aee90e071f61322254"
        @asset_manager_id_for_960_asset = "2222f0aee90e071f6af146159"
        @asset_manager_id_for_300_asset = "1111f0aee90e071f6af146229"
        @data = {
          "images" => [
            {
              "lead_image" => true,
              "variants" => [
                {
                  "file_url" => "https://assets.publishing.service.gov.uk/media/#{@asset_manager_id_for_original_asset}/highres.jpg",
                  "variant" => "high_resolution",
                },
                {
                  "file_url" => "https://assets.publishing.service.gov.uk/media/#{@asset_manager_id_for_960_asset}/960.jpg",
                  "variant" => "960",
                },
                {
                  "file_url" => "https://assets.publishing.service.gov.uk/media/#{@asset_manager_id_for_300_asset}/300.jpg",
                  "variant" => "300",
                },
              ],
            },
          ],
        }
      end

      it "saves lead image to the edition" do
        Whitehall::DocumentImporter.save_images(@data, @edition)
        assert_equal 1, @edition.images.count
        assert_equal @edition.images.first.image_data_id.to_s, @edition.block_content["image"] # == Lead image
      end

      it "maps image variants to their closest Whitehall equivalents" do
        Whitehall::DocumentImporter.save_images(@data, @edition)
        image_data = @edition.images.first.image_data
        assert_equal 7, image_data.assets.count
        assert_equal @asset_manager_id_for_original_asset, image_data.assets.find_by(variant: "original").asset_manager_id
        assert_equal "highres.jpg", image_data.assets.find_by(variant: "original").filename
        assert_equal @asset_manager_id_for_960_asset, image_data.assets.find_by(variant: "s960").asset_manager_id
        assert_equal "960.jpg", image_data.assets.find_by(variant: "s960").filename
        assert_equal @asset_manager_id_for_960_asset, image_data.assets.find_by(variant: "s712").asset_manager_id
        assert_equal "960.jpg", image_data.assets.find_by(variant: "s712").filename
        assert_equal @asset_manager_id_for_960_asset, image_data.assets.find_by(variant: "s630").asset_manager_id
        assert_equal "960.jpg", image_data.assets.find_by(variant: "s630").filename
        assert_equal @asset_manager_id_for_960_asset, image_data.assets.find_by(variant: "s465").asset_manager_id
        assert_equal "960.jpg", image_data.assets.find_by(variant: "s465").filename
        assert_equal @asset_manager_id_for_300_asset, image_data.assets.find_by(variant: "s300").asset_manager_id
        assert_equal "300.jpg", image_data.assets.find_by(variant: "s300").filename
        assert_equal @asset_manager_id_for_300_asset, image_data.assets.find_by(variant: "s216").asset_manager_id
        assert_equal "300.jpg", image_data.assets.find_by(variant: "s216").filename
      end
    end
  end
end
