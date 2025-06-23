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

  let(:edition) { create(:content_block_edition, :pension, details: { "something" => { "embedded" => { "title" => "Embedded", "is" => "here" } } }) }
  let(:group) { nil }

  let(:stub_schema) { stub("schema", body: [], name: "Schema") }
  let(:stub_subschema) { stub("subschema", name: "Something", block_type: object_type, fields: [], permitted_params: %w[title is], id: "something", group:) }

  let(:object_type) { "something" }

  before do
    ContentBlockManager::ContentBlock::Schema.stubs(:find_by_block_type).with(edition.document.block_type).returns(stub_schema)
    stub_schema.stubs(:subschema).with(object_type).returns(stub_subschema)
  end

  describe "#new" do
    describe "when an object type is provided" do
      it "fetches the subschema and renders the template" do
        get content_block_manager.new_embedded_object_content_block_manager_content_block_edition_path(
          edition,
          object_type,
        )

        assert_equal assigns(:content_block_edition), edition
        assert_equal assigns(:schema), stub_schema
        assert_equal assigns(:subschema), stub_subschema

        assert_template :new
      end
    end

    describe "when no object type is provided" do
      describe "when a group is provided" do
        it "renders a list of subschemas for the group" do
          group = "my_group"
          subschemas = [stub_subschema]

          stub_schema.stubs(:subschemas_for_group).with(group).returns(subschemas)

          get content_block_manager.new_embedded_object_content_block_manager_content_block_edition_path(
            edition,
            group:,
          )

          assert_equal assigns(:content_block_edition), edition
          assert_equal assigns(:schema), stub_schema
          assert_equal assigns(:group), group
          assert_equal assigns(:subschemas), subschemas
          assert_equal assigns(:back_link), content_block_manager.content_block_manager_content_block_workflow_path(
            edition,
            step: "group_#{group}",
          )
          assert_equal assigns(:redirect_path), content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_edition_path(edition)
          assert_equal assigns(:context), edition.title

          assert_template "content_block_manager/content_block/shared/embedded_objects/select_subschema"
        end

        it "404s if no schemas exist for a given group" do
          group = "my_group"
          subschemas = []
          stub_schema.stubs(:subschemas_for_group).with(group).returns(subschemas)

          get content_block_manager.new_embedded_object_content_block_manager_content_block_edition_path(
            edition,
            group:,
          )

          assert_equal response.status, 404
        end
      end
    end
  end

  describe "#new_embedded_objects_options_redirect" do
    describe "when the object_type param is provided" do
      before do
        post content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_edition_path(
          edition,
          object_type: "something",
          group: "something",
        )
      end

      it "redirects to the path for that object" do
        assert_redirected_to content_block_manager.new_embedded_object_content_block_manager_content_block_edition_path(edition, object_type: "something")
      end

      it "sets the back link as a flash" do
        assert_equal content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_edition_path(
          edition,
          group: "something",
        ), flash[:back_link]
      end
    end

    describe "when the object_type param is not provided" do
      it "redirects back to the schema select page with an error" do
        post content_block_manager.new_embedded_objects_options_redirect_content_block_manager_content_block_edition_path(
          edition,
          object_type: nil,
          group: "something",
        )

        assert_redirected_to content_block_manager.new_embedded_object_content_block_manager_content_block_edition_path(
          edition,
          group: "something",
        )
        assert_equal I18n.t("activerecord.errors.models.content_block_manager/content_block/document.attributes.block_type.blank"), flash[:error]
      end
    end
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
        edition, step: "#{Workflow::Step::SUBSCHEMA_PREFIX}#{object_type}"
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

    describe "when the subschema belongs to a group" do
      let(:group) { "some_group" }

      it "should redirect to the group step" do
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
          edition, step: "#{Workflow::Step::GROUP_PREFIX}#{group}"
        )
        assert_equal "Something added. You can add another some group or finish creating the schema block.", flash[:notice]
      end
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

    describe "when the subschema belongs to a group" do
      let(:group) { "some_group" }

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
        assert_equal "Something edited. You can add another some group or finish creating the schema block.", flash[:notice]
      end
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
