require "test_helper"

class ContentBlockManager::PublishableTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  class PublishableTestClass
    include ContentBlockManager::Publishable
  end

  describe "#create_draft_edition" do
    let(:schema) { build(:content_block_schema) }
    let(:content_block_edition) { build(:content_block_edition, :email_address) }

    let(:publishable_test_instance) { PublishableTestClass.new }

    it "raises an error if a block isn't passed since changes need to be made locally" do
      assert_raises ArgumentError, "Local database changes not given" do
        publishable_test_instance.create_draft_edition(schema)
      end
    end

    it "creates a draft edition" do
      Services.publishing_api.expects(:put_content).with(
        content_block_edition.document.content_id,
        {
          schema_name: schema.id,
          document_type: schema.id,
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          title: content_block_edition.title,
          content_id_alias: content_block_edition.document.content_id_alias,
          details: content_block_edition.details,
          instructions_to_publishers: content_block_edition.instructions_to_publishers,
          links: {
            primary_publishing_organisation: [
              content_block_edition.lead_organisation.content_id,
            ],
          },
        },
      )

      publishable_test_instance.create_draft_edition(schema) do
        content_block_edition
      end
    end
  end
end
