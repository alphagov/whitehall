require "test_helper"

module Whitehall
  class DocumentImporterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    setup do
      @robot_user = User.create!(name: "Scheduled Publishing Robot", email: "robot@example.com")
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
        "internal_history" => [],
        "attachments" => [],
        "images" => [],
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
        data = @data.merge({
          "created_by" => "someone-who-does-not-exist-in-whitehall@example.com",
        })
        edition = Whitehall::DocumentImporter.create_base_edition!(data)
        assert_equal @robot_user, edition.creator
      end
    end

    describe ".robot_user" do
      it "retrieves the robot user" do
        assert_equal @robot_user, Whitehall::DocumentImporter.robot_user
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

    describe "importing a 'withdrawn' document" do
      it "creates an unpublishing with the correct attributes" do
        data = @data.merge(
          "state" => "withdrawn",
          "internal_history" => [
            {
              "edition_number" => 1,
              "entry_type" => "withdrawn",
              "date" => "29 January 2020",
              "time" => "4:01pm",
              "user" => "foo@gov.uk",
              "entry_content" => "This page is now withdrawn",
            },
            {
              "edition_number" => 2,
              "entry_type" => "draft_discarded",
              "date" => "30 September 2019",
              "time" => "11:47am",
              "user" => "bar@gov.uk",
              "entry_content" => nil,
            },
          ],
          "base_path" => "/government/news/imported-news-story",
        )
        edition = Whitehall::DocumentImporter.create_base_edition!(data)
        assert_equal "2020-01-29 16:01:00 +0000", edition.unpublishing.created_at.to_s
        assert_equal "2020-01-29 16:01:00 +0000", edition.unpublishing.updated_at.to_s
        assert_equal "This page is now withdrawn", edition.unpublishing.explanation
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

      it "drops contacts if they no longer exist" do
        body_input = <<~BODY
          ## Foo

          Bar

          [Contact: random-content-id-that-does-not-exist]
        BODY
        expected_body_output = <<~BODY
          ## Foo

          Bar


        BODY

        body_output = Whitehall::DocumentImporter.pre_process_body(body_input)

        assert_equal expected_body_output, body_output
      end

      it "replaces footnotes with their definitions" do
        body_input = <<~BODY
          ## Table 3: Estimated number of households eligible

          Local Authority|Households eligible for the means-tested payment[^1]|Individuals eligible for the disability payment*
          -|-:|-:
          Aberdeen City|22,900|18,200
          Aberdeenshire|19,800|18,500

          Some more content. This is some text with a footnote.[^2]

          More text.

          [^1]: Estimates rounded to the nearest 100. Cases categorised as abroad or unknown have not been included in the totals.
          [^2]: Estimates rounded to the nearest 100. Cases categorised as abroad or unknown have not been included in the totals.
        BODY
        expected_body_output = <<~BODY
          ## Table 3: Estimated number of households eligible

          Local Authority|Households eligible for the means-tested payment (Estimates rounded to the nearest 100. Cases categorised as abroad or unknown have not been included in the totals.)|Individuals eligible for the disability payment*
          -|-:|-:
          Aberdeen City|22,900|18,200
          Aberdeenshire|19,800|18,500

          Some more content. This is some text with a footnote. (Estimates rounded to the nearest 100. Cases categorised as abroad or unknown have not been included in the totals.)

          More text.

        BODY

        body_output = Whitehall::DocumentImporter.pre_process_body(body_input)

        assert_equal expected_body_output, body_output
      end
    end

    describe ".combined_change_notes" do
      it "combines change notes into a single string" do
        change_notes = [
          { "public_timestamp" => 1.day.ago.iso8601, "note" => "Second note" },
          { "public_timestamp" => 2.days.ago.iso8601, "note" => "First note" },
        ]
        expected_output = "#{1.day.ago.strftime('%-d %B %Y')}: Second note; #{2.days.ago.strftime('%-d %B %Y')}: First note"
        assert_equal expected_output, Whitehall::DocumentImporter.combined_change_notes(change_notes)
      end
    end

    describe ".internal_history_summary" do
      it "returns the internal history summary" do
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

        expected_output = <<~OUTPUT
          Imported from Content Publisher. Document history:<br><br>
          • 25 May 2022 10:24am: Approved by foo.bar@gov.uk<br>
          • 20 May 2022 11:50pm: Internal note by baz@gov.uk. Details: Removed typo.
        OUTPUT
        assert_equal expected_output.gsub("\n", ""), Whitehall::DocumentImporter.internal_history_summary(internal_history)
      end
    end

    describe ".save_attachments" do
      setup do
        # Minimal stub of a callback, otherwise the `skip_callback` call raises exception.
        AttachmentData.set_callback(:save, :before, :update_file_attributes)
        # Stub the actual method so it does nothing
        AttachmentData.any_instance.stubs(:update_file_attributes)
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
        @edition = create(:standard_edition, configurable_document_type: "news_story", block_content: { "body" => "foo" })
        @asset_manager_id_for_original_asset = "3333f0aee90e071f61322254"
        @asset_manager_id_for_960_asset = "2222f0aee90e071f6af146159"
        @asset_manager_id_for_300_asset = "1111f0aee90e071f6af146229"
        @data = {
          "images" => [
            {
              "created_at" => "2022-05-25 08:17:06 +0100",
              "caption" => "Caption for the image",
              "alt_text" => "Delegates attending the G7 meeting in Germany.",
              "credit" => "",
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

      it "carries over the image 'created_at' date" do
        Whitehall::DocumentImporter.save_images(@data, @edition)
        assert_equal "2022-05-25 08:17:06 +0100", @edition.images.first.created_at.to_s
      end

      it "carries over the image 'alt_text'" do
        Whitehall::DocumentImporter.save_images(@data, @edition)
        assert_equal "Delegates attending the G7 meeting in Germany.", @edition.images.first.alt_text
      end

      it "carries over the image 'caption'" do
        Whitehall::DocumentImporter.save_images(@data, @edition)
        assert_equal "Caption for the image", @edition.images.first.caption
      end

      it "appends credit onto the image caption" do
        @data["images"].first["credit"] = "Image credit"
        Whitehall::DocumentImporter.save_images(@data, @edition)
        assert_equal "Caption for the image. Credit: Image credit", @edition.images.first.caption
      end

      it "saves lead image to the edition" do
        Whitehall::DocumentImporter.save_images(@data, @edition)
        assert_equal 1, @edition.images.count
        assert_equal @edition.images.first.image_data_id, @edition.reload.block_content["image"] # == Lead image
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
