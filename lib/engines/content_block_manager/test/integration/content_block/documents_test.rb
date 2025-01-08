require "test_helper"
require "capybara/rails"

class ContentBlockManager::ContentBlock::DocumentsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  setup do
    logout
    @organisation = create(:organisation)
    user = create(:gds_admin, organisation: @organisation)
    login_as(user)
  end

  describe "#index" do
    it "only returns the latest edition when multiple editions exist for a document" do
      content_block_document = create(:content_block_document, :email_address)
      first_edition = create(
        :content_block_edition,
        :email_address,
        details: { "email_address" => "first_edition@example.com" },
        document_id: content_block_document.id,
        organisation: @organisation,
      )
      second_edition = create(
        :content_block_edition,
        :email_address,
        details: { "email_address" => "second_edition@example.com" },
        document_id: content_block_document.id,
        organisation: @organisation,
      )

      visit content_block_manager.content_block_manager_content_block_documents_path

      assert_no_text first_edition.details["email_address"]
      assert_text second_edition.details["email_address"]
    end

    it "only returns documents with a latest edition" do
      document_with_latest_edition = create(:content_block_document, :email_address)
      document_with_latest_edition.latest_edition = create(
        :content_block_edition,
        :email_address,
        details: { "email_address" => "live_edition@example.com" },
        document_id: document_with_latest_edition.id,
      )
      _document_without_latest_edition = create(:content_block_document, :email_address, sluggable_string: "no latest edition")

      visit content_block_manager.content_block_manager_content_block_documents_path({ lead_organisation: "" })

      assert_text document_with_latest_edition.latest_edition.details["email_address"]
      assert_text "1 result"
    end

    describe "when no filter params are specified" do
      describe "when there are no session filters" do
        it "sets the filter to 'all organisations' by default" do
          visit content_block_manager.content_block_manager_content_block_documents_path

          assert_current_path content_block_manager.content_block_manager_root_path({ lead_organisation: "" })
        end
      end

      describe "when there are session filters" do
        before do
          visit content_block_manager.content_block_manager_content_block_documents_path({ keyword: "something" })
        end

        it "adds them to the params by default the next time user visits" do
          visit content_block_manager.content_block_manager_content_block_documents_path

          assert_current_path content_block_manager.content_block_manager_root_path({ keyword: "something" })
        end

        it "resets the filters when reset_fields is set" do
          visit content_block_manager.content_block_manager_content_block_documents_path({ reset_fields: true })

          assert_current_path content_block_manager.content_block_manager_root_path({ lead_organisation: "" })
        end
      end
    end

    describe "when there are filter params provided" do
      it "does not change the params" do
        visit content_block_manager.content_block_manager_content_block_documents_path({ lead_organisation: "123" })

        assert_current_path content_block_manager.content_block_manager_content_block_documents_path({ lead_organisation: "123" })
      end
    end
  end

  describe "#new" do
    let(:schemas) { build_list(:content_block_schema, 1, body: { "properties" => {} }) }

    it "lists all schemas" do
      ContentBlockManager::ContentBlock::Schema.expects(:all).returns(schemas)

      visit new_content_block_manager_content_block_document_path

      assert_text "Select a content block"
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

  describe "#show" do
    let(:edition) { create(:content_block_edition, :email_address) }
    let(:document) { edition.document }

    it "returns information about the document" do
      stub_publishing_api_has_embedded_content_for_any_content_id(
        results: [],
        total: 0,
        order: ContentBlockManager::GetHostContentItems::DEFAULT_ORDER,
      )

      visit content_block_manager_content_block_document_path(document)

      assert_text document.title
    end

    it_returns_embedded_content do
      visit content_block_manager_content_block_document_path(document)
    end
  end

  describe "#content_id" do
    it "returns 404 if the document doesn't exist" do
      visit content_block_manager_content_block_content_id_path("123")
      assert_text "Could not find Content Block with Content ID 123"
    end
  end
end
