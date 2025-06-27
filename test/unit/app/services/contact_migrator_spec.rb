require "test_helper"

describe ContactMigrator do
  include ActiveSupport::Testing::Assertions # for `assert_difference`
  include FactoryBot::Syntax::Methods # for `create(:obj)` methods
  include GdsApi::TestHelpers::PublishingApi # for `stub_any_publishing_api_call`

  before do
    User.create!(name: "Scheduled Publishing Robot") unless User.find_by(name: "Scheduled Publishing Robot")
  end

  let(:contact_mapping) do
    [
      {
        old_contact_id: 100,
        new_contact_id: 200,
        confidence: "exact match",
        details: "foo",
      },
    ]
  end

  let(:bad_body) { "[Contact:100]" }

  describe "initialising the service" do
    it "raises if neither edition_id nor html_attachment_id is provided" do
      assert_raises(ArgumentError) do
        ContactMigrator.call(contact_mapping: contact_mapping)
      end
    end

    it "raises if both edition_id and html_attachment_id are provided" do
      assert_raises(ArgumentError) do
        ContactMigrator.call(
          edition_id: 1,
          html_attachment_id: 2,
          contact_mapping: contact_mapping,
        )
      end
    end

    it "raises if edition_id is provided without contact_mapping" do
      assert_raises(ArgumentError) do
        ContactMigrator.call(edition_id: 1)
      end
    end

    it "raises if html_attachment_id is provided without contact_mapping" do
      assert_raises(ArgumentError) do
        ContactMigrator.call(html_attachment_id: 2)
      end
    end

    it "does not raise if edition_id and contact_mapping are provided" do
      fake_edition = Edition.new(id: 1)
      fake_edition.stubs(:update!).returns(true)

      Edition.stub(:find, fake_edition) do
        ContactMigrator.call(edition_id: 1, contact_mapping: contact_mapping)
      end
    end

    it "does not raise if html_attachment_id and contact_mapping are provided" do
      fake_edition = create(:published_edition) # Edition.new
      ContactMigrator.any_instance.stubs(:publish_edition) #  avoid publishing as that's not what we're testing here

      fake_html_attachment = create(:html_attachment, attachable: fake_edition)
      fake_html_attachment.govspeak_content.update!(body: bad_body)
      HtmlAttachment.stub(:find, fake_html_attachment) do
        ContactMigrator.call(html_attachment_id: fake_html_attachment.id, contact_mapping: contact_mapping)
      end
    end
  end

  describe "validating the passed parameters" do
    it "raises exception if referenced Edition doesn't exist" do
      assert_raises(ActiveRecord::RecordNotFound) do
        ContactMigrator.call(edition_id: -1, contact_mapping: contact_mapping)
      end
    end

    it "raises exception if referenced HtmlAttachment doesn't exist" do
      assert_raises(ActiveRecord::RecordNotFound) do
        ContactMigrator.call(html_attachment_id: -1, contact_mapping: contact_mapping)
      end
    end

    it "warns if referenced Edition is anything other than Draft/Submitted/Rejected/Published" do
      edition = create(:unpublished_edition, body: bad_body)

      messages = capture_rails_logger(level: :debug) do
        ContactMigrator.call(edition_id: edition.id, contact_mapping: contact_mapping)
      end

      expected_message = "Unable to process edition #{edition.id} due to its state (unpublished)"
      assert_includes messages.join("\n"), expected_message
    end

    it "warns if Edition associated with referenced HTML Attachment is anything other than Draft/Submitted/Rejected/Published" do
      edition = create(:unpublished_edition)
      attachment = create(:html_attachment, attachable: edition)
      attachment.govspeak_content.update!(body: bad_body)
      messages = capture_rails_logger(level: :debug) do
        ContactMigrator.call(html_attachment_id: attachment.id, contact_mapping: contact_mapping)
      end

      expected_message = "Unable to process HTML attachment #{attachment.id} due to its parent edition state (edition ID: #{edition.id}, state: unpublished)"
      assert_includes messages.join("\n"), expected_message
    end
  end

  describe "replacing bad contact IDs in Editions" do
    it "avoids creating or publishing an Edition in the first place if no changes are required" do
      body    = "Only good contact: [Contact:3]"
      edition = create(:published_edition, body:)

      # Nothing should be published, nothing created
      ContactMigrator.any_instance.expects(:publish_edition).never

      assert_difference -> { Edition.where(document: edition.document).count }, 0 do
        ContactMigrator.call(edition_id: edition.id, contact_mapping: contact_mapping)
      end

      _(edition.reload.body).must_equal body
    end

    it "creates draft Edition if referenced Edition is Published" do
      published = create(:published_edition, body: bad_body)

      assert_difference -> { Edition.where(document: published.document).count }, +1 do
        ContactMigrator.any_instance.stubs(:publish_edition) #  avoid publishing as that's not what we're testing here
        ContactMigrator.call(edition_id: published.id, contact_mapping: contact_mapping)
      end

      latest_edition = Edition.where(document: published.document).order(:id).last
      assert_equal "draft", latest_edition.state, "The new edition should be a draft"
      _(published.id).wont_equal(latest_edition.id)
    end

    it "finds and replaces bad contact IDs on the draft edition, leaving other contact IDs untouched" do
      body = <<~GOVSPEAK
        Good contact: [Contact:3]
        Bad contact: [Contact:100]
        Bad contact again: [Contact:100]
        Another good contact: [Contact:7]
      GOVSPEAK
      edition = create(:edition, body:)

      expected_updated_body = <<~GOVSPEAK
        Good contact: [Contact:3]
        Bad contact: [Contact:200]
        Bad contact again: [Contact:200]
        Another good contact: [Contact:7]
      GOVSPEAK

      ContactMigrator.call(edition_id: edition.id, contact_mapping: contact_mapping)

      assert_equal expected_updated_body, edition.document.latest_edition.reload.body
    end

    it "publishes the updated edition if (and only if) the original edition was 'published'" do
      stub_any_publishing_api_call
      published = create(:published_edition, body: bad_body)
      ContactMigrator.call(edition_id: published.id, contact_mapping: contact_mapping)
      assert_equal "published", published.document.latest_edition.state

      # have chosen `submitted`` here but could also have chosen `draft`` or `rejected`
      submitted = create(:submitted_edition, body: bad_body)
      ContactMigrator.call(edition_id: submitted.id, contact_mapping: contact_mapping)
      assert_equal "submitted", submitted.document.latest_edition.state
    end
  end

  describe "replacing bad contact IDs in HTML Attachments" do
    it "avoids creating or publishing an Edition in the first place if no changes are required" do
      published_edition = create(:published_edition)
      attachment = create(:html_attachment, attachable: published_edition)

      # Nothing should be published, nothing created
      ContactMigrator.any_instance.expects(:publish_edition).never

      assert_difference -> { Edition.where(document: published_edition.document).count }, 0 do
        ContactMigrator.call(html_attachment_id: attachment.id, contact_mapping: contact_mapping)
      end
    end

    it "creates draft Edition if referenced HTML Attachment's Edition is Published" do
      published_edition = create(:published_edition)
      attachment = create(:html_attachment, attachable: published_edition)
      attachment.govspeak_content.update!(body: bad_body)
      assert_difference -> { Edition.where(document: published_edition.document).count }, +1 do
        ContactMigrator.any_instance.stubs(:publish_edition) #  avoid publishing as that's not what we're testing here
        ContactMigrator.call(html_attachment_id: attachment.id, contact_mapping: contact_mapping)
      end

      latest_edition = Edition.where(document: published_edition.document).order(:id).last
      assert_equal "draft", latest_edition.state, "The new edition should be a draft"
      _(published_edition.id).wont_equal(latest_edition.id)
    end

    it "finds and replaces bad contact IDs on the draft edition's HTML attachment, leaving other contact IDs untouched" do
      stub_any_publishing_api_call
      published_edition = create(:published_edition)
      body = <<~GOVSPEAK
        Good contact: [Contact:3]
        Bad contact: [Contact:100]
        Bad contact again: [Contact:100]
        Another good contact: [Contact:7]
      GOVSPEAK
      attachment = create(:html_attachment, body:, attachable: published_edition)
      # we have to bypass validations in order for our custom slug to persist:
      attachment.update_column(:slug, "made-up-slug")

      expected_updated_body = <<~GOVSPEAK
        Good contact: [Contact:3]
        Bad contact: [Contact:200]
        Bad contact again: [Contact:200]
        Another good contact: [Contact:7]
      GOVSPEAK

      ContactMigrator.call(html_attachment_id: attachment.id, contact_mapping: contact_mapping)

      assert_equal(
        expected_updated_body,
        # creating new editions also creates new copies of their HTML attachments, so we need
        # to dynamically fetch the created copy of the HTML attachment to check if it's been
        # updated. Hence the 🤢 chain below.
        published_edition.document.latest_edition.reload.html_attachments.find_by(slug: "made-up-slug").body,
      )
    end

    it "publishes the updated edition if (and only if) the edition associated with the original HTML Attachment was 'published'" do
      stub_any_publishing_api_call
      published_edition = create(:published_edition)
      attachment = create(:html_attachment, body: bad_body, attachable: published_edition)
      ContactMigrator.call(html_attachment_id: attachment.id, contact_mapping: contact_mapping)
      assert_equal "published", published_edition.document.latest_edition.state

      # have chosen `submitted` here but could also have chosen `draft`` or `rejected`
      submitted_edition = create(:submitted_edition)
      attachment = create(:html_attachment, body: bad_body, attachable: submitted_edition)
      ContactMigrator.call(html_attachment_id: attachment.id, contact_mapping: contact_mapping)
      assert_equal "submitted", submitted_edition.document.latest_edition.state
    end
  end

  def capture_rails_logger(level: :debug)
    messages = []
    original_logger = Rails.logger

    Rails.logger = ActiveSupport::Logger.new(StringIO.new).tap do |logger|
      logger.level = Logger.const_get(level.to_s.upcase)
      logger.formatter = ->(_severity, _time, _progname, msg) { messages << msg }
    end

    yield

    messages
  ensure
    Rails.logger = original_logger
  end
end
