require "test_helper"
require "capybara/rails"

class ContentBlockManager::ContentBlock::EditionsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers
  include ContentBlockManager::IntegrationTestHelpers

  before do
    login_as_admin
  end

  describe "#new" do
    describe "when a document id is provided" do
      let!(:original_edition) { create(:content_block_edition, :email_address, document: content_block_document) }
      let(:content_block_document) { create(:content_block_document, :email_address) }

      it "initializes the form for the latest edition" do
        ContentBlockManager::ContentBlock::Document.expects(:find).with(content_block_document.id.to_s).returns(content_block_document)
        schema = stub_request_for_schema(content_block_document.block_type)
        form = stub(:form, title: "title", url: "url", back_path: "back_path", content_block_edition: original_edition, schema:, attributes: {}, form_method: :post)
        ContentBlockManager::ContentBlock::EditionForm.expects(:for).with(
          content_block_edition: original_edition,
          schema:,
        ).returns(form)

        visit content_block_manager.new_content_block_manager_content_block_document_edition_path(content_block_document)

        assert_text "Edit content block"
      end
    end

    describe "when a document id is not provided" do
      it "initializes the form for the latest edition" do
        edition = create(:content_block_edition, :email_address)
        ContentBlockManager::ContentBlock::Edition.expects(:new).returns(edition)
        schema = stub_request_for_schema("block_type")
        form = stub(:form, title: "title", url: "url", back_path: "back_path", content_block_edition: edition, schema:, attributes: {}, form_method: :post)
        ContentBlockManager::ContentBlock::EditionForm.expects(:for).with(
          content_block_edition: edition,
          schema:,
        ).returns(form)

        visit content_block_manager.new_content_block_manager_content_block_edition_path(block_type: "block-type")

        assert_text "Create content block"
      end
    end
  end

  describe "#create" do
    let(:content_block_document) { create(:content_block_document, :email_address) }
    let!(:original_edition) { create(:content_block_edition, :email_address, document: content_block_document) }

    let(:title) { "Some Title" }
    let(:document_attributes) do
      {
        block_type: "email_address",
      }.with_indifferent_access
    end
    let(:details) do
      {
        "foo" => "Foo text",
        "bar" => "Bar text",
      }
    end
    let(:organisation) { create(:organisation) }

    let!(:schema) { stub_request_for_schema("email_address") }

    describe "when updating an existing block" do
      it "creates a new content block with params generated by the schema" do
        assert_changes -> { content_block_document.editions.count }, from: 1, to: 2 do
          assert_changes -> { ContentBlockManager::ContentBlock::Version.count }, from: 1, to: 2 do
            post content_block_manager.content_block_manager_content_block_document_editions_path(content_block_document), params: {
              something: "else",
              "content_block/edition": {
                document_attributes:,
                details:,
                organisation_id: organisation.id,
                title:,
              },
            }
          end
        end

        content_block_document.reload
        new_edition = content_block_document.editions.last
        new_author = ContentBlockManager::ContentBlock::EditionAuthor.last
        new_version = ContentBlockManager::ContentBlock::Version.last
        new_edition_organisation = ContentBlockManager::ContentBlock::EditionOrganisation.last

        assert_equal document_attributes[:block_type], content_block_document.block_type
        assert_equal title, new_edition.title
        assert_equal details, new_edition.details

        assert_equal new_edition.document_id, content_block_document.id
        assert_equal new_edition.creator, new_author.user

        assert_equal new_version.whodunnit, new_author.user.id.to_s

        assert_equal new_edition_organisation.organisation_id, organisation.id
        assert_equal new_edition_organisation.content_block_edition_id, new_edition.id
      end

      it "should render the template when a validation error is raised" do
        renders_errors do
          post content_block_manager.content_block_manager_content_block_document_editions_path(content_block_document), params: {
            "content_block/edition": {
              document_attributes: {
                block_type: "email_address",
              },
            },
          }
        end
      end

      it "redirects to the review links step when successful" do
        redirects_to_step(:review_links) do
          post content_block_manager.content_block_manager_content_block_document_editions_path(content_block_document), params: {
            "content_block/edition": {
              document_attributes: {
                block_type: "email_address",
              },
            },
          }
        end
      end

      describe "when subschemas are present" do
        let(:subschemas) { [stub("subschema", id: "my_subschema_name")] }
        let!(:schema) { stub_request_for_schema("email_address", subschemas:) }

        before do
          ContentBlockManager::ContentBlock::Edition.any_instance.stubs(:has_entries_for_subschema_id?).with("my_subschema_name").returns(true)
        end

        it "redirects to the first subschema step when successful" do
          redirects_to_step(:embedded_my_subschema_name) do
            post content_block_manager.content_block_manager_content_block_document_editions_path(content_block_document), params: {
              "content_block/edition": {
                document_attributes: {
                  block_type: "email_address",
                },
              },
            }
          end
        end
      end
    end

    describe "when creating a new block" do
      before do
        ContentBlockManager::ContentBlock::Document.any_instance.stubs(:is_new_block?).returns(true)
      end

      it "creates a new content block with params generated by the schema" do
        post content_block_manager.content_block_manager_content_block_editions_path, params: {
          something: "else",
          "content_block/edition": {
            document_attributes:,
            details:,
            title:,
            organisation_id: organisation.id,
          },
        }

        edition = ContentBlockManager::ContentBlock::Edition.last
        document = edition.document
        author = ContentBlockManager::ContentBlock::EditionAuthor.last
        version = ContentBlockManager::ContentBlock::Version.last
        edition_organisation = ContentBlockManager::ContentBlock::EditionOrganisation.last

        assert_equal title, edition.title
        assert_equal document_attributes[:block_type], document.block_type
        assert_equal details, edition.details

        assert_equal edition.document_id, document.id
        assert_equal edition.creator, author.user

        assert_equal version.whodunnit, author.user.id.to_s

        assert_equal edition_organisation.organisation_id, organisation.id
        assert_equal edition_organisation.content_block_edition_id, edition.id
      end

      it "should render the template when a validation error is raised" do
        renders_errors do
          post content_block_manager.content_block_manager_content_block_editions_path, params: {
            something: "else",
            "content_block/edition": {
              document_attributes:,
              details:,
              organisation_id: organisation.id,
            },
          }
        end
      end

      it "redirects to the review step when successful" do
        redirects_to_step(:review) do
          post content_block_manager.content_block_manager_content_block_editions_path, params: {
            something: "else",
            "content_block/edition": {
              document_attributes:,
              details:,
              organisation_id: organisation.id,
            },
          }
        end
      end

      describe "when subschemas are present" do
        let(:subschemas) { [stub("subschema", id: "my_subschema_name")] }
        let!(:schema) { stub_request_for_schema("email_address", subschemas:) }

        it "redirects to the first subschema step when successful" do
          redirects_to_step(:embedded_my_subschema_name) do
            post content_block_manager.content_block_manager_content_block_editions_path, params: {
              something: "else",
              "content_block/edition": {
                document_attributes:,
                details:,
                organisation_id: organisation.id,
              },
            }
          end
        end
      end
    end
  end
end

def renders_errors(&block)
  content_block_edition = build(:content_block_edition, :email_address)
  ContentBlockManager::CreateEditionService.any_instance.expects(:call).raises(ActiveRecord::RecordInvalid, content_block_edition)
  block.call
  assert_template "content_block_manager/content_block/editions/new"
end

def redirects_to_step(step, &block)
  content_block_edition = build(:content_block_edition, :email_address, id: 123)
  ContentBlockManager::CreateEditionService.any_instance.expects(:call).returns(content_block_edition)
  block.call
  assert_redirected_to content_block_manager_content_block_workflow_path(id: content_block_edition.id, step:)
end
