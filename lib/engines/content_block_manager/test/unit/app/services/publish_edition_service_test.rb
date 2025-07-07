require "test_helper"

class ContentBlockManager::PublishEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:schema) { build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
    let(:document) { create(:content_block_document, :pension, content_id:, sluggable_string: "some-edition-title") }
    let(:major_change) { true }
    let(:edition) do
      create(
        :content_block_edition,
        document:,
        details: { "foo" => "Foo text", "bar" => "Bar text" },
        organisation: @organisation,
        instructions_to_publishers: "instructions",
        title: "Some Edition Title",
        change_note: "Something changed publicly",
        major_change:,
      )
    end

    setup do
      ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type)
                                               .returns(schema)
      @organisation = create(:organisation)
    end

    it "returns a ContentBlockEdition" do
      result = ContentBlockManager::PublishEditionService.new.call(edition)
      assert_instance_of ContentBlockManager::ContentBlock::Edition, result
    end

    it "publishes the Edition in Whitehall" do
      ContentBlockManager::SchedulePublishingWorker.expects(:dequeue).never

      ContentBlockManager::PublishEditionService.new.call(edition)
      assert_equal "published", edition.state
      assert_equal edition.id, document.live_edition_id
    end

    it "creates an Edition in the Publishing API" do
      Services.publishing_api.expects(:put_content).with(
        content_id,
        {
          schema_name: schema.id,
          document_type: schema.id,
          publishing_app: "whitehall",
          title: "Some Edition Title",
          content_id_alias: "some-edition-title",
          instructions_to_publishers: "instructions",
          details: {
            "foo" => "Foo text",
            "bar" => "Bar text",
          },
          links: {
            primary_publishing_organisation: [@organisation.content_id],
          },
          update_type: "major",
          change_note: edition.change_note,
        },
      )

      Services.publishing_api.expects(:publish).with(content_id, "content_block")

      ContentBlockManager::PublishEditionService.new.call(edition)

      assert_equal "published", edition.state
      assert_equal edition.id, document.live_edition_id
    end

    describe "when the change is not major" do
      let(:major_change) { false }

      it "sends a minor update_type with no change note to the Publishing API" do
        Services.publishing_api.expects(:put_content).with do |_content_id, payload|
          payload[:update_type]
          payload[:change_note].nil?
        end

        Services.publishing_api.stubs(:publish)

        ContentBlockManager::PublishEditionService.new.call(edition)

        assert_equal "published", edition.state
        assert_equal edition.id, document.live_edition_id
      end
    end

    it "rolls back the Whitehall ContentBlockEdition and ContentBlockDocument if the publishing API request fails" do
      Services.publishing_api.stubs(:put_content).raises(
        GdsApi::HTTPErrorResponse.new(
          422,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        ),
      )

      assert_equal "draft", edition.state
      assert_nil document.live_edition_id

      assert_raises(GdsApi::HTTPErrorResponse) do
        ContentBlockManager::PublishEditionService.new.call(edition)
      end

      assert_equal "draft", edition.state
      assert_nil document.live_edition_id
    end

    it "discards the latest draft if the publish request fails" do
      Services.publishing_api.stubs(:put_content)
      Services.publishing_api.stubs(:publish).raises(
        GdsApi::HTTPErrorResponse.new(
          422,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        ),
      )

      Services.publishing_api.expects(:discard_draft).with(content_id)

      assert_raises(ContentBlockManager::PublishEditionService::PublishingFailureError, "Could not publish #{content_id} because: Some backend error") do
        ContentBlockManager::PublishEditionService.new.call(edition)
      end

      assert_equal "draft", edition.state
      assert_nil document.live_edition_id
    end

    it "supersedes any previously scheduled editions" do
      scheduled_editions = create_list(:content_block_edition, 2,
                                       document:,
                                       scheduled_publication: 7.days.from_now,
                                       state: "scheduled")

      scheduled_editions.each do |scheduled_edition|
        ContentBlockManager::SchedulePublishingWorker.expects(:dequeue).with(scheduled_edition)
      end

      ContentBlockManager::PublishEditionService.new.call(edition)

      scheduled_editions.each do |scheduled_edition|
        assert scheduled_edition.reload.superseded?
      end
    end
  end
end
