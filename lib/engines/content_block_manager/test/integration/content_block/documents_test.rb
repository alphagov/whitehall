require "test_helper"
require "capybara/rails"

class ContentBlockManager::ContentBlock::DocumentsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  setup do
    login_as_admin

    feature_flags.switch!(:content_block_manager, true)
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

      visit content_block_manager.content_block_manager_content_block_documents_path

      assert_no_text first_edition.details["email_address"]
      assert_text second_edition.details["email_address"]
    end

    it "only returns documents with a latest edition" do
      document_with_latest_edition = build(:content_block_document, :email_address, id: 123)
      document_with_latest_edition.latest_edition = build(
        :content_block_edition,
        :email_address,
        details: { "email_address" => "live_edition@example.com" },
        document_id: document_with_latest_edition.id,
      )

      ContentBlockManager::ContentBlock::Document.expects(:live).returns([document_with_latest_edition])

      visit content_block_manager.content_block_manager_content_block_documents_path

      assert_text document_with_latest_edition.latest_edition.details["email_address"]
    end
  end

  describe "#new" do
    let(:schemas) { build_list(:content_block_schema, 1, body: { "properties" => {} }) }

    it "lists all schemas" do
      ContentBlockManager::ContentBlock::Schema.expects(:all).returns(schemas)

      visit new_content_block_manager_content_block_document_path

      assert_text "Select a block type"
    end
  end

  describe "#new_document_options_redirect" do
    let(:schemas) { build_list(:content_block_schema, 1, body: { "properties" => {} }) }

    before do
      ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(schemas)
    end

    it "shows an error message when block type is empty" do
      post new_document_options_redirect_content_block_manager_content_block_documents_path
      follow_redirect!

      assert_equal new_content_block_manager_content_block_document_path, path
      assert_equal "You must select a block type", flash[:error]
    end

    it "redirects when the block type is specified" do
      block_type = schemas[0].block_type
      ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).returns(schemas[0])

      post new_document_options_redirect_content_block_manager_content_block_documents_path, params: { block_type: }
      follow_redirect!

      assert_equal new_content_block_manager_content_block_edition_path(block_type:), path
    end
  end
end
