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

  let(:edition) { create(:content_block_edition, :email_address, details: { "something" => { "embedded" => { "name" => "Embedded", "is" => "here" } } }) }

  let(:stub_schema) { stub("schema", body: []) }
  let(:stub_subschema) { stub("subschema", name: object_type, block_type: object_type, fields: [], permitted_params: %w[name is]) }

  let(:object_type) { "something" }

  before do
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(edition.document.block_type).returns(stub_schema)
    stub_schema.stubs(:subschema).with(object_type).returns(stub_subschema)
  end

  describe "#edit" do
    it "should fetch an object of a particular type" do
      get content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_name: "embedded",
      )

      assert_equal assigns(:content_block_edition), edition
      assert_equal assigns(:schema), stub_schema
      assert_equal assigns(:subschema), stub_subschema
      assert_equal assigns(:object_name), "embedded"
      assert_equal assigns(:object), { "is" => "here", "name" => "Embedded" }
    end

    it "should 404 if the subschema does not exist" do
      stub_schema.stubs(:subschema).with("something_else").returns(nil)

      get content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type: "something_else",
        object_name: "embedded",
      )

      assert_equal response.status, 404
    end

    it "should 404 if the object cannot be found" do
      stub_schema.stubs(:subschema).with("something_else").returns(nil)

      get content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_name: "something_else",
      )

      assert_equal response.status, 404
    end
  end

  describe "#update" do
    it "should update an embedded object for an edition" do
      put content_block_manager.embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_name: "embedded",
      ), params: {
        "content_block/edition" => {
          details: {
            object_type => {
              "name" => "Embedded",
              "is" => "different",
            },
          },
        },
      }

      assert_redirected_to content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_name: "embedded",
      )

      updated_edition = edition.reload

      assert_equal updated_edition.details, { "something" => { "embedded" => { "name" => "Embedded", "is" => "different" } } }
    end

    it "should rename the object if a new name is given" do
      put content_block_manager.embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_name: "embedded",
      ), params: {
        "content_block/edition" => {
          details: {
            object_type => {
              "name" => "New Name",
              "is" => "different",
            },
          },
        },
      }

      assert_redirected_to content_block_manager.review_embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_name: "new-name",
      )

      updated_edition = edition.reload

      assert_equal updated_edition.details, { "something" => { "new-name" => { "name" => "New Name", "is" => "different" } } }
    end

    it "should render errors if a validation error is thrown" do
      ContentBlockManager::ContentBlock::Edition.any_instance.stubs(:save!).raises(ActiveRecord::RecordInvalid)

      put content_block_manager.embedded_object_content_block_manager_content_block_edition_path(
        edition,
        object_type:,
        object_name: "embedded",
      ), params: {
        "content_block/edition" => {
          details: {
            object_type => {
              "name" => "New Name",
              "is" => "different",
            },
          },
        },
      }

      assert_equal assigns(:content_block_edition), edition
      assert_equal assigns(:schema), stub_schema
      assert_equal assigns(:subschema), stub_subschema
      assert_equal assigns(:object_name), "embedded"
      assert_equal assigns(:object).to_h, {
        "name" => "New Name",
        "is" => "different",
      }

      assert_template :edit
    end
  end
end
