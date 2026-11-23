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
    assert_select "form[action=?][method=post]", admin_standard_edition_navigation_path(parent_edition) do
      assert_select "button[type=submit]", text: "Add navigation menu"
    end
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

  test "PATCH update returns a 404 for documents that don't support navigation" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => false },
    }))
    edition = create(:standard_edition, configurable_document_type: "test_type")
    login_as :writer

    patch :update, params: { standard_edition_id: edition.id, child_document_ids: [] }

    assert_response :not_found
  end

  test "PATCH update creates navigation items for the selected child pages and redirects to the Navigation tab" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    parent_edition = create(:draft_standard_edition)
    first_child, second_child, third_child = create_list(:draft_standard_edition, 3)
    [first_child, second_child, third_child].each do |child_edition|
      ParentChildRelationship.create!(parent_edition:, child_document: child_edition.document)
    end
    login_as :writer

    patch :update, params: { standard_edition_id: parent_edition.id, child_document_ids: [first_child.document_id, third_child.document_id] }

    assert_redirected_to navigation_admin_standard_edition_path(parent_edition)
    assert_equal [first_child.document_id, third_child.document_id].sort, parent_edition.navigation_edition.navigation_items.pluck(:child_document_id).sort
  end

  test "PATCH update replaces the existing navigation items with the selection" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    parent_edition = create(:draft_standard_edition)
    kept_child, removed_child, added_child = create_list(:draft_standard_edition, 3)
    [kept_child, removed_child, added_child].each do |child_edition|
      ParentChildRelationship.create!(parent_edition:, child_document: child_edition.document)
    end
    [kept_child, removed_child].each do |child_edition|
      create(:navigation_item, navigation_edition: parent_edition.navigation_edition, child_document: child_edition.document)
    end
    login_as :writer

    patch :update, params: { standard_edition_id: parent_edition.id, child_document_ids: [kept_child.document_id, added_child.document_id] }

    assert_equal [kept_child.document_id, added_child.document_id].sort, parent_edition.navigation_edition.navigation_items.reload.pluck(:child_document_id).sort
  end

  view_test "PATCH update shows an error and changes nothing if a selected document is not a child page of the edition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    parent_edition = create(:draft_standard_edition)
    existing_child = create(:draft_standard_edition)
    new_child = create(:draft_standard_edition)
    [existing_child, new_child].each do |child_edition|
      ParentChildRelationship.create!(parent_edition:, child_document: child_edition.document)
    end
    create(:navigation_item, navigation_edition: parent_edition.navigation_edition, child_document: existing_child.document)
    unrelated_edition = create(:draft_standard_edition)
    login_as :writer

    patch :update, params: { standard_edition_id: parent_edition.id, child_document_ids: [new_child.document_id, unrelated_edition.document_id] }

    assert_response :unprocessable_entity
    assert_equal "You can only add child pages of this document to the navigation menu", flash[:alert]
    assert_select "input[type=checkbox][value=?]", new_child.document_id.to_s
    assert_equal [existing_child.document_id], parent_edition.navigation_edition.navigation_items.reload.pluck(:child_document_id)
  end

  view_test "PATCH update shows an error and changes nothing if a selected child page is one the user cannot see" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    parent_edition = create(:draft_standard_edition)
    visible_child = create(:draft_standard_edition)
    hidden_child = create(:draft_standard_edition, :access_limited_by_organisations)
    [visible_child, hidden_child].each do |child_edition|
      ParentChildRelationship.create!(parent_edition:, child_document: child_edition.document)
    end
    login_as :writer

    patch :update, params: { standard_edition_id: parent_edition.id, child_document_ids: [visible_child.document_id, hidden_child.document_id] }

    assert_response :unprocessable_entity
    assert_equal "You can only add child pages of this document to the navigation menu", flash[:alert]
    assert_empty parent_edition.navigation_edition.navigation_items.reload
  end

  test "PATCH update only changes the navigation items of the edition being edited, not those of earlier editions" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    published_parent_edition = create(:draft_standard_edition)
    child_edition = create(:draft_standard_edition)
    ParentChildRelationship.create!(parent_edition: published_parent_edition, child_document: child_edition.document)
    create(:navigation_item, navigation_edition: published_parent_edition.navigation_edition, child_document: child_edition.document)
    published_parent_edition.major_change_published_at = Time.zone.now
    published_parent_edition.force_publish!
    draft_parent_edition = published_parent_edition.create_draft(create(:writer))
    login_as :writer

    patch :update, params: { standard_edition_id: draft_parent_edition.id }

    assert_empty draft_parent_edition.navigation_edition.navigation_items.reload
    assert_equal [child_edition.document_id], published_parent_edition.navigation_edition.navigation_items.reload.pluck(:child_document_id)
  end

  test "PATCH update with no child pages selected empties the navigation" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "navigation_enabled" => true, "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))
    parent_edition = create(:draft_standard_edition)
    child_edition = create(:draft_standard_edition)
    ParentChildRelationship.create!(parent_edition:, child_document: child_edition.document)
    create(:navigation_item, navigation_edition: parent_edition.navigation_edition, child_document: child_edition.document)
    login_as :writer

    patch :update, params: { standard_edition_id: parent_edition.id }

    assert_redirected_to navigation_admin_standard_edition_path(parent_edition)
    assert_empty parent_edition.navigation_edition.navigation_items.reload
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

    test "PATCH :update is forbidden for an existing mini_site_landing" do
      edition = create(:standard_edition, configurable_document_type: "mini_site_landing")

      patch :update, params: { standard_edition_id: edition }

      assert_response :forbidden
    end
  end
end
