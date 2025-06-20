require "test_helper"
require "capybara/rails"

class ContentBlockManager::ContentBlock::Documents::EmbeddedObjectsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  setup do
    logout
    @organisation = create(:organisation)
    user = create(:gds_admin, organisation: @organisation)
    login_as(user)
  end

  let(:document) { build_stubbed(:content_block_document, :pension) }

  before do
    ContentBlockManager::ContentBlock::Document.stubs(:find).with(document.id.to_s).returns(document)
  end

  describe "#new" do
    let(:schema) { stub(:schema) }

    before do
      ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(document.block_type).returns(schema)
    end

    describe "when an object_type is given" do
      let(:subschema) { ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new("schema_1", { "patternProperties" => { "foo" => "bar" } }, "schema") }

      before do
        schema.stubs(:subschema).with(anything).returns(subschema)
        subschema.stubs(:field_names).returns([])
        ContentBlockManager::ContentBlock::Documents::EmbeddedObjectsController
          .any_instance
          .stubs(:flash)
          .returns({ back_link: })
      end

      describe "when a back link is not present in the flash" do
        let(:back_link) { nil }

        it "sets a default back link" do
          get content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
            document,
            object_type: "something",
          )

          assert_equal assigns(:back_link), content_block_manager.content_block_manager_content_block_document_path(document)
        end
      end

      describe "when a back link is present in the flash" do
        let(:back_link) { "somewhere/else" }

        it "sets the back link from the flash" do
          get content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
            document,
            object_type: "something",
          )

          assert_equal assigns(:back_link), "somewhere/else"
        end
      end
    end

    describe "when object_type is not given" do
      describe "and a group param is provided" do
        let(:subschemas_for_group) do
          [
            ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new("schema_1", { "patternProperties" => { "foo" => "bar" } }, "schema"),
            ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new("schema_2", { "patternProperties" => { "foo" => "bar" } }, "schema"),
          ]
        end
        let(:group) { "my_group" }

        it "renders with subschemas for that group when the group exists" do
          schema.stubs(:subschemas_for_group).with(group).returns(subschemas_for_group)

          get content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
            document,
            group:,
          )

          assert_equal assigns(:content_block_document), document
          assert_equal assigns(:schema), schema
          assert_equal assigns(:group), group
          assert_equal assigns(:subschemas), subschemas_for_group

          assert_template :select_subschema
        end

        it "returns a 404 when no schemas can be found for that group" do
          schema.stubs(:subschemas_for_group).with(group).returns([])

          get content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
            document,
            group:,
          )

          assert_equal response.status, 404
        end
      end

      describe "when no subschema is found" do
        it "returns a 404" do
          schema.stubs(:subschemas_for_group).with(nil).returns([])

          get content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
            document,
            group: nil,
          )

          assert_equal response.status, 404
        end
      end
    end
  end

  describe "#new_embedded_objects_options_redirect" do
    describe "when the object_type param is provided" do
      before do
        post content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_document_embedded_objects_path(
          document,
          object_type: "something",
          group: "something",
        )
      end

      it "redirects to the path for that object" do
        assert_redirected_to content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(document, object_type: "something")
      end

      it "sets the back link as a flash" do
        assert_equal content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
          document,
          group: "something",
        ), flash[:back_link]
      end
    end

    describe "when the object_type param is not provided" do
      it "redirects back to the schema select page with an error" do
        post content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_document_embedded_objects_path(
          document,
          object_type: nil,
          group: "something",
        )

        assert_redirected_to content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
          document,
          group: "something",
        )
        assert_equal I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank"), flash[:error]
      end
    end
  end
end
