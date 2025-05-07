require "test_helper"
require "capybara/rails"

class ContentBlockManager::ContentBlock::Editions::EmbeddedObjectsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  setup do
    logout
    @organisation = create(:organisation)
    user = create(:gds_admin, organisation: @organisation)
    login_as(user)
  end

  let(:edition) { create(:content_block_edition, :email_address, details: { "something" => { "embedded" => { "title" => "Embedded", "is" => "here" } } }) }

  let(:stub_schema) { stub("schema", body: [], name: "Schema") }
  let(:stub_subschema) { stub("subschema", name: "Something", block_type: object_type, fields: [], permitted_params: %w[title is], id: "something") }

  let(:object_type) { "something" }

  before do
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(edition.document.block_type).returns(stub_schema)
    stub_schema.stubs(:subschema).with(object_type).returns(stub_subschema)
  end

  describe "#create" do
    it "should create an embedded object for an edition" do
      post content_block_manager.create_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
      ), params: {
        "content_block/edition" => {
          details: {
            object_type => {
              "title" => "New Thing",
              "is" => "something",
            },
          },
        },
      }

      assert_redirected_to content_block_manager.content_block_manager_content_block_workflow_path(
        edition, step: :embedded_objects
      )

      updated_edition = edition.reload

      assert_equal updated_edition.details, {
        "something" => {
          "embedded" => {
            "title" => "Embedded", "is" => "here"
          },
          "new-thing" => {
            "title" => "New Thing", "is" => "something"
          },
        },
      }
      assert_equal "Something added. You can add another something or finish creating the schema block.", flash[:notice]
    end
  end

  describe "#edit" do
    it "should fetch an object of a particular type" do
      get content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      )

      assert_equal assigns(:content_block_edition), edition
      assert_equal assigns(:schema), stub_schema
      assert_equal assigns(:subschema), stub_subschema
      assert_equal assigns(:object_title), "embedded"
      assert_equal assigns(:object), { "is" => "here", "title" => "Embedded" }
    end

    it "should assign the redirect_url if given" do
      get content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
        redirect_url: "https://example.com",
      )

      assert_equal assigns(:redirect_url), "https://example.com"
    end

    it "should 404 if the subschema does not exist" do
      stub_schema.stubs(:subschema).with("something_else").returns(nil)

      get content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type: "something_else",
        object_title: "embedded",
      )

      assert_equal response.status, 404
    end

    it "should 404 if the object cannot be found" do
      stub_schema.stubs(:subschema).with("something_else").returns(nil)

      get content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "something_else",
      )

      assert_equal response.status, 404
    end
  end

  describe "#update" do
    it "should update an embedded object for an edition" do
      put content_block_manager.embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      ), params: {
        "content_block/edition" => {
          details: {
            object_type => {
              "title" => "Embedded",
              "is" => "different",
            },
          },
        },
      }

      assert_redirected_to content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      )

      updated_edition = edition.reload

      assert_equal updated_edition.details, { "something" => { "embedded" => { "title" => "Embedded", "is" => "different" } } }
    end

    it "should redirect if a redirect_url is given" do
      put content_block_manager.embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      ), params: {
        redirect_url: content_block_manager.content_block_manager_content_block_documents_path,
        "content_block/edition" => {
          details: {
            object_type => {
              "title" => "Embedded",
              "is" => "different",
            },
          },
        },
      }

      assert_redirected_to content_block_manager.content_block_manager_content_block_documents_path
      assert_equal "Something edited. You can add another something or finish creating the schema block.", flash[:notice]
    end

    it "should not rename the object if a new title is given" do
      put content_block_manager.embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      ), params: {
        "content_block/edition" => {
          details: {
            object_type => {
              "title" => "New Name",
              "is" => "different",
            },
          },
        },
      }

      assert_redirected_to content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      )

      updated_edition = edition.reload

      assert_equal updated_edition.details, { "something" => { "embedded" => { "title" => "New Name", "is" => "different" } } }
    end

    it "should render errors if a validation error is thrown" do
      ContentBlockManager::ContentBlock::Edition.any_instance.stubs(:save!).raises(ActiveRecord::RecordInvalid)

      put content_block_manager.embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_title: "embedded",
      ), params: {
        "content_block/edition" => {
          details: {
            object_type => {
              "title" => "New Name",
              "is" => "different",
            },
          },
        },
      }

      assert_equal assigns(:content_block_edition), edition
      assert_equal assigns(:schema), stub_schema
      assert_equal assigns(:subschema), stub_subschema
      assert_equal assigns(:object_title), "embedded"
      assert_equal assigns(:object).to_h, {
        "title" => "New Name",
        "is" => "different",
      }

      assert_template :edit
    end
  end
end
