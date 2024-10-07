require "test_helper"
require "capybara/rails"

class ContentObjectStore::ContentBlock::EditionsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include ContentObjectStore::Engine.routes.url_helpers

  setup do
    login_as_admin

    feature_flags.switch!(:content_object_store, true)
  end

  describe "#index" do
    it "only returns the latest edition when multiple editions exist for a document" do
      content_block_document = create(:content_block_document, :email_address)
      first_edition = create(
        :content_block_edition,
        :email_address,
        details: { "email_address" => "first_edition@example.com" },
        document_id: content_block_document.id,
      )
      second_edition = create(
        :content_block_edition,
        :email_address,
        details: { "email_address" => "second_edition@example.com" },
        document_id: content_block_document.id,
      )

      visit content_object_store.content_object_store_content_block_documents_path

      assert_no_text first_edition.details["email_address"]
      assert_text second_edition.details["email_address"]
    end
  end

  describe "#new" do
    let(:schemas) { build_list(:content_block_schema, 1, body: { "properties" => {} }) }

    it "lists all schemas when no block type is provided" do
      ContentObjectStore::ContentBlock::Schema.expects(:all).returns(schemas)

      visit new_content_object_store_content_block_document_path

      assert_text "Select a block type"
    end

    it "shows the form when a block type is provided" do
      block_type = "block_type"
      ContentObjectStore::ContentBlock::Schema.expects(:find_by_block_type).with(block_type).returns(schemas[0])

      visit new_content_object_store_content_block_document_path(block_type:)

      assert_text "Create Block type"
    end
  end

  describe "#new_document_options_redirect" do
    let(:schemas) { build_list(:content_block_schema, 1, body: { "properties" => {} }) }

    before do
      ContentObjectStore::ContentBlock::Schema.stubs(:all).returns(schemas)
    end

    it "shows an error message when block type is empty" do
      post new_document_options_redirect_content_object_store_content_block_documents_path
      follow_redirect!

      assert_equal new_content_object_store_content_block_document_path, path
      assert_equal "You must select a block type", flash[:error]
    end

    it "redirects when the block type is specified" do
      block_type = schemas[0].block_type
      ContentObjectStore::ContentBlock::Schema.stubs(:find_by_block_type).returns(schemas[0])

      post new_document_options_redirect_content_object_store_content_block_documents_path, params: { block_type: }
      follow_redirect!

      assert_equal new_content_object_store_content_block_document_path(block_type:), path
    end
  end

  describe "#create" do
    let(:schema) { build(:content_block_schema, body: { "properties" => {} }) }
    let(:edition_service) { stub(:edition_service) }
    let(:params) do
      {
        something: "else",
        block_type: "something",
        "content_block/edition": {
          document_attributes: { "title": "foo" },
          organisation_id: 123,
        },
      }
    end
    let(:content_block_edition) { build_stubbed(:content_block_edition) }

    before do
      ContentObjectStore::CreateEditionService.expects(:new).returns(edition_service)
      ContentObjectStore::ContentBlock::Schema.expects(:find_by_block_type).returns(schema)
    end

    it "creates a document and redirects when successful" do
      edition_service.expects(:call).returns(content_block_edition)

      post(content_object_store_content_block_documents_path, params:)

      assert_redirected_to content_object_store_content_block_workflow_path(content_block_edition, step: ContentObjectStore::ContentBlock::Editions::WorkflowController::NEW_BLOCK_STEPS[:review])
    end
  end
end
