require "test_helper"

class ContentBlockManager::CreateEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let!(:organisation) { create(:organisation) }

    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:schema) { build(:content_block_schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
    let(:new_title) { "New Title" }
    let(:edition_params) do
      {
        document_attributes: {
          title: new_title,
          block_type: "email_address",
        }.with_indifferent_access,
        details: {
          "foo" => "Foo text",
          "bar" => "Bar text",
        },
        creator: build(:user),
        organisation_id: organisation.id.to_s,
      }
    end

    setup do
      # This UUID is created by the database so instead of loading the record
      # we stub the initial creation so we know what UUID to check for.
      ContentBlockManager::ContentBlock::Edition.any_instance.stubs(:create_random_id)
                                             .returns(content_id)

      ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type)
                                            .returns(schema)
    end

    it "returns a ContentBlockEdition" do
      result = ContentBlockManager::CreateEditionService.new(schema).call(edition_params)
      assert_instance_of ContentBlockManager::ContentBlock::Edition, result
    end

    it "creates a ContentBlockEdition in Whitehall" do
      assert_changes -> { ContentBlockManager::ContentBlock::Document.count }, from: 0, to: 1 do
        assert_changes -> { ContentBlockManager::ContentBlock::Edition.count }, from: 0, to: 1 do
          ContentBlockManager::CreateEditionService.new(schema).call(edition_params)
        end
      end

      new_document = ContentBlockManager::ContentBlock::Document.find_by!(content_id:)
      new_edition = new_document.editions.first

      assert_equal new_title, new_document.title
      assert_equal edition_params[:document_attributes][:block_type], new_document.block_type
      assert_equal edition_params[:details], new_edition.details
      assert_equal new_edition.document_id, new_document.id
      assert_equal new_edition.lead_organisation.id, organisation.id
    end

    it "sends the content block to the Publishing API as a draft" do
      assert_draft_created_in_publishing_api(content_id:, content_id_alias: new_title.parameterize) do
        ContentBlockManager::CreateEditionService.new(schema).call(edition_params)
      end
    end

    describe "when a document id is provided" do
      let(:document) { create(:content_block_document, :email_address) }
      let!(:previous_edition) { create(:content_block_edition, :email_address, document:) }

      it "creates a new edition for that document" do
        assert_no_changes -> { ContentBlockManager::ContentBlock::Document.count } do
          assert_changes -> { document.reload.editions.count }, from: 1, to: 2 do
            ContentBlockManager::CreateEditionService.new(schema).call(edition_params, document_id: document.id)
          end
        end

        new_edition = document.editions.last

        assert_equal new_title, document.title
        assert_equal edition_params[:details], new_edition.details
        assert_equal new_edition.document_id, document.id
        assert_equal new_edition.lead_organisation.id, organisation.id
      end

      it "sends the content block to the Publishing API as a draft" do
        assert_draft_created_in_publishing_api(content_id: document.content_id, content_id_alias: document.content_id_alias) do
          ContentBlockManager::CreateEditionService.new(schema).call(edition_params, document_id: document.id)
        end
      end
    end
  end
end

def assert_draft_created_in_publishing_api(content_id:, content_id_alias:, &block)
  Services.publishing_api.expects(:put_content).with(
    content_id,
    {
      schema_name: schema.id,
      document_type: schema.id,
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      title: new_title,
      content_id_alias:,
      details: edition_params[:details],
      instructions_to_publishers: edition_params[:instructions_to_publishers],
      links: {
        primary_publishing_organisation: [
          organisation.content_id,
        ],
      },
    },
  )

  block.call
end
