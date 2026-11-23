require "test_helper"

class Admin::StandardEditionNavigationsControllerTest < ActionController::TestCase
  extend Minitest::Spec::DSL

  should_be_an_admin_controller

  setup do
    @organisation = create(:organisation)
    login_as :writer, @organisation
  end

  view_test "GET edit returns a 404 for documents that don't support navigation" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => false },
    }))
    edition = create(:standard_edition, configurable_document_type: "test_type")
    login_as :managing_editor

    get :edit, params: { standard_edition_id: edition.id }

    assert_response :not_found
  end

  view_test "GET edit lists the visible child pages as checkboxes with an 'Add navigation menu' button and a cancel link" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    parent_edition = create(:draft_standard_edition)
    visible_child = create(:draft_standard_edition, title: "Visible child")
    hidden_child = create(:draft_standard_edition, :access_limited_by_organisations, title: "Hidden child")
    [visible_child, hidden_child].each do |child_edition|
      ParentChildRelationship.create!(parent_edition:, child_document: child_edition.document)
    end
    login_as :writer

    get :edit, params: { standard_edition_id: parent_edition.id }

    assert_response :success
    assert_select "input[type=checkbox][value=?]", visible_child.document.id.to_s
    assert_select "label", text: "Visible child"
    assert_select "label", text: "Hidden child", count: 0
    assert_select "button[type=submit]", text: "Add navigation menu"
    assert_select "a[href=?]", navigation_admin_standard_edition_path(parent_edition), text: "Cancel"
  end

  view_test "GET edit shows an 'Update navigation menu' button when the navigation has items" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    parent_edition = create(:draft_standard_edition)
    child_edition = create(:draft_standard_edition)
    ParentChildRelationship.create!(parent_edition:, child_document: child_edition.document)
    create(:navigation_item, navigation_edition: parent_edition.navigation_edition, child_document: child_edition.document)
    login_as :writer

    get :edit, params: { standard_edition_id: parent_edition.id }

    assert_response :success
    assert_select "button[type=submit]", text: "Update navigation menu"
    assert_select "button", text: "Add navigation menu", count: 0
  end

  describe "when the mini_sites feature flag is disabled" do
    setup do
      ConfigurableDocumentType.setup_test_types(
        build_configurable_document_type("mini_site_landing", { "settings" => { "navigation_enabled" => true } }),
      )
      @feature_flags.switch!(:mini_sites, false)
    end

    test "GET :edit is forbidden for an existing mini_site_landing" do
      edition = create(:standard_edition, configurable_document_type: "mini_site_landing")

      get :edit, params: { standard_edition_id: edition }

      assert_response :forbidden
    end
  end
end
