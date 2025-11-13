require "test_helper"

class Admin::StandardEditionsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @organisation = create(:organisation)
    login_as :gds_admin, @organisation

    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:configurable_document_types, true)
  end

  teardown do
    @test_strategy.switch!(:configurable_document_types, false)
  end

  test "GET new returns a not found response when the configurable documents feature flag is disabled" do
    @test_strategy.switch!(:configurable_document_types, false)
    get :new
    assert_response :not_found
    assert_template "admin/errors/not_found"
  end

  test "GET new returns a not_found response when no configurable_document_type parameter is provided" do
    get :new
    assert_response :not_found
    assert_template "admin/errors/not_found"
  end

  view_test "GET choose_type scopes the list of types to types that the user has permission to use" do
    configurable_document_type_user_org = build_configurable_document_type("test_type", { "title" => "Test Type One", "settings" => { "organisations" => [@current_user.organisation.content_id] } })
    configurable_document_type_other_org = build_configurable_document_type("other_type", { "title" => "Test Type Two", "settings" => { "organisations" => [SecureRandom.uuid] } })

    ConfigurableDocumentType.setup_test_types(configurable_document_type_user_org
                                                .merge(configurable_document_type_other_org))
    get :choose_type
    assert_response :ok
    assert_dom "label", "Test Type One"
    refute_dom "label", "Test Type Two"
  end

  view_test "GET choose_type displays only top-level and 'group' types by default" do
    top_level_type = build_configurable_document_type("top_level_type", { "title" => "Top level type" })
    child_type = build_configurable_document_type("child_type", { "title" => "Child type", "settings" => { "configurable_document_group" => "parent_type" } })
    ConfigurableDocumentType.setup_test_types(top_level_type.merge(child_type))
    get :choose_type
    assert_response :ok
    assert_dom "h1", "New standard document"
    assert_dom "label", "Top level type"
    assert_dom "label", "Parent type"
    refute_dom "label", "Child type"
  end

  view_test "GET choose_type displays only the 'group' types where are least one child type is permitted for the user" do
    non_permitted_child_type = build_configurable_document_type("non_permitted_child_type", { "title" => "Non-permitted Child Type", "settings" => { "configurable_document_group" => "parent_type", "organisations" => [SecureRandom.uuid] } })
    ConfigurableDocumentType.setup_test_types(non_permitted_child_type)
    get :choose_type
    assert_response :ok
    assert_dom "h1", "New standard document"
    refute_dom "label", "Parent type"
  end

  view_test "GET choose_type displays child types when a 'group' configurable_document_type parameter is provided" do
    parent_type = build_configurable_document_type("parent_type", { "title" => "Parent Type" })
    child_type = build_configurable_document_type("child_type", { "title" => "Child Type", "settings" => { "configurable_document_group" => "parent_type" } })
    ConfigurableDocumentType.setup_test_types(parent_type.merge(child_type))
    get :choose_type, params: { configurable_document_type: "parent_type" }
    assert_response :ok
    assert_dom "h1", "New parent type"
    refute_dom "label", "Parent Type"
    assert_dom "label", "Child Type"
  end

  view_test "GET choose_type redirects to the new edition form when a 'groupless' configurable_document_type parameter is provided" do
    parent_type = build_configurable_document_type("parent_type", { "title" => "Parent Type" })
    child_type = build_configurable_document_type("child_type", { "title" => "Child Type", "settings" => { "configurable_document_group" => "parent_type" } })
    ConfigurableDocumentType.setup_test_types(parent_type.merge(child_type))
    get :choose_type, params: { configurable_document_type: "child_type" }
    assert_redirected_to new_admin_standard_edition_path(configurable_document_type: "child_type")
  end

  view_test "GET choose_type returns a not found response when an invalid configurable_document_type parameter is provided" do
    get :choose_type, params: { configurable_document_type: "non_existent_type" }
    assert_response :not_found
    assert_template "admin/errors/not_found"
  end

  view_test "GET change_type shows only permitted sibling types in the same group as the current edition's type" do
    current_type = build_configurable_document_type("current_type", { "title" => "Current Type", "settings" => { "configurable_document_group" => "group_type" } })
    permitted_sibling_type = build_configurable_document_type("permitted_sibling_type", { "title" => "Permitted Sibling Type", "settings" => { "configurable_document_group" => "group_type", "organisations" => [@current_user.organisation.content_id] } })
    non_permitted_sibling_type = build_configurable_document_type("non_permitted_sibling_type", { "title" => "Non-permitted Sibling Type", "settings" => { "configurable_document_group" => "group_type", "organisations" => [SecureRandom.uuid] } })
    permitted_non_sibling_type = build_configurable_document_type("permitted_non_sibling_type", { "title" => "Permitted Non-sibling Type", "settings" => { "organisations" => [@current_user.organisation.content_id] } })
    ConfigurableDocumentType.setup_test_types(
      current_type.merge(permitted_sibling_type)
        .merge(non_permitted_sibling_type)
        .merge(permitted_non_sibling_type),
    )
    edition = create(:standard_edition, configurable_document_type: "current_type")
    get :change_type, params: { id: edition.id }
    assert_response :ok
    assert_dom "label", permitted_sibling_type["permitted_sibling_type"]["title"]
    refute_dom "label", current_type["current_type"]["title"]
    refute_dom "label", non_permitted_sibling_type["non_permitted_sibling_type"]["title"]
    refute_dom "label", permitted_non_sibling_type["permitted_non_sibling_type"]["title"]
  end

  view_test "GET change_type shows error message if the edition is not in a draft state" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    edition = create(:published_standard_edition, configurable_document_type: "test_type")
    get :change_type, params: { id: edition.id }
    assert_response :ok
    assert_dom "h1", "Cannot change document type"
    assert_dom "p", "You can only change the document type of draft editions."
  end

  view_test "GET change_type shows error message if the current document type cannot be changed" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    edition = create(:standard_edition, :draft, configurable_document_type: "test_type")

    @controller.instance_variable_set(:@available_types, [])

    get :change_type, params: { id: edition.id }
    assert_response :ok
    assert_dom "h1", "Cannot change document type"
    assert_dom "p", "It is not possible to change the type of this document."
  end

  view_test "GET change_type_preview shows the document type change preview" do
    old_type = build_configurable_document_type("old_type", { "title" => "Old Type" })
    new_type = build_configurable_document_type("new_type", { "title" => "New Type", "settings" => { "configurable_document_group" => "group_type" } })
    ConfigurableDocumentType.setup_test_types(old_type.merge(new_type))
    edition = create(:standard_edition, configurable_document_type: "old_type")
    get :change_type_preview, params: { id: edition.id, configurable_document_type: "new_type" }
    assert_response :ok
    assert_dom "h1", "Preview document type change"
  end

  view_test "GET edit renders default fields for a standard document" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:standard_edition, :with_organisations)
    edition.save!

    get :edit, params: { id: edition }

    assert_response :ok
    assert_select "label", text: "Title (required)"
    assert_select "label", text: "Summary (required)"
    assert_select "legend", text: "Limit access"
    assert_select "legend", text: "Schedule publication"
    assert_select "legend", text: "Review date"
  end

  view_test "GET edit renders previously published form controls if backdating is enabled" do
    configurable_document_type = build_configurable_document_type("test_type", { "settings" => { "backdating_enabled" => true } })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:standard_edition, :with_organisations)
    edition.save!

    get :edit, params: { id: edition }

    assert_response :ok
    assert_select "legend", text: "First published date"
  end

  view_test "GET edit renders the history mode form controls when history mode is enabled" do
    configurable_document_type = build_configurable_document_type("test_type", { "settings" => { "history_mode_enabled" => true } })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:published_standard_edition, :with_organisations)
    edition.save!

    draft = edition.create_draft(edition.authors.first)
    login_as :managing_editor
    get :edit, params: { id: draft.id }

    assert_response :ok
    assert_select "legend", text: "Political"
  end

  view_test "GET edit renders Attachments tab and alternative format provider select when file attachments are enabled" do
    configurable_document_type = build_configurable_document_type("test_type", { "settings" => { "file_attachments_enabled" => true } })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = create(:draft_standard_edition, :with_organisations)

    login_as :managing_editor
    get :edit, params: { id: edition.id }

    assert_response :ok
    assert_select "a[href=\"#{admin_edition_attachments_path(edition)}\"]", text: "Attachments"
    assert_select "#edition_alternative_format_provider_id"
  end

  view_test "GET edit does not render the Attachments tab when file attachments are disabled" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = create(:draft_standard_edition, :with_organisations)

    login_as :managing_editor
    get :edit, params: { id: edition.id }

    assert_response :ok
    assert_select "a[href=\"#{admin_edition_attachments_path(edition)}\"]", false
  end

  view_test "GET edit renders the form controls for the configured associations" do
    configurable_document_type = build_configurable_document_type("test_type", { "associations" => [
      {
        "key" => "ministerial_role_appointments",
      },
      {
        "key" => "topical_events",
      },
      {
        "key" => "world_locations",
      },
      {
        "key" => "organisations",
      },
      {
        "key" => "worldwide_organisations",
      },
    ] })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    create(:world_location)
    edition = create(:draft_standard_edition, :with_organisations)

    login_as :managing_editor
    get :edit, params: { id: edition.id }
    assert_response :ok
    assert_select "h2", text: "Associations"
    assert_select "label", text: "Ministers"
    assert_select "label", text: "Topical events"
    assert_select "label", text: "World locations"
    assert_select "legend", text: "Lead organisations"
    assert_select "label", text: "Supporting organisations"
    assert_select "label", text: "Worldwide organisations"
  end

  view_test "GET edit renders the 'Update document slug' checkbox when editing a new draft of a published edition" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    published_edition = create(:published_standard_edition, :with_organisations)
    draft_edition = published_edition.create_draft(published_edition.authors.first)

    login_as :managing_editor
    get :edit, params: { id: draft_edition.id }

    assert_response :ok
    assert_select "label", text: "Update document slug"
    assert_select "input[type='checkbox'][name='edition[should_update_document_slug]']"
  end

  view_test "GET show displays the document path in the summary list" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = create(:draft_standard_edition)
    stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

    login_as :managing_editor
    get :show, params: { id: edition.id }

    assert_response :ok
    assert_select ".govuk-summary-list__row" do
      assert_select ".govuk-summary-list__key", text: "Path"
      assert_select ".govuk-summary-list__value", text: edition.base_path
    end
  end

  view_test "PATCH update respects a provided safe relative redirect_to path" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = create(
      :draft_standard_edition,
      :with_organisations,
      configurable_document_type: "test_type",
      title: "Title",
      summary: "Summary",
    )

    # Make update succeed without invoking the service layer
    @controller.stubs(:updater).returns(stub(can_perform?: true, perform!: true, failure_reason: nil))
    StandardEdition.any_instance.stubs(:save_as).with(current_user).returns(true)

    custom_path = admin_edition_images_path(edition) # => /government/admin/editions/:id/images

    patch :update, params: {
      id: edition.id,
      # minimal permitted attrs to avoid strong params rejection
      edition: { title: edition.title, summary: edition.summary, configurable_document_type: "test_type" },
      redirect_to: custom_path,
      save: "save",
    }

    assert_redirected_to custom_path
  end

  view_test "PATCH update does not allow open redirects and falls back to edit page" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = create(
      :draft_standard_edition,
      :with_organisations,
      configurable_document_type: "test_type",
      title: "Title",
      summary: "Summary",
    )

    @controller.stubs(:updater).returns(stub(can_perform?: true, perform!: true, failure_reason: nil))
    StandardEdition.any_instance.stubs(:save_as).with(current_user).returns(true)

    fallback_path = edit_admin_standard_edition_path(edition)

    patch :update, params: {
      id: edition.id,
      edition: { title: edition.title, summary: edition.summary, configurable_document_type: "test_type" },
      redirect_to: "https://evil.example/phish",
      save: "save",
    }

    assert_redirected_to fallback_path
  end

  view_test "POST create re-renders the new edition template with the submitted block content and errors if the form is invalid" do
    configurable_document_type = build_configurable_document_type("test_type", "schema" => {
      "validations" => {
        "presence" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    block_content = {
      "test_attribute" => "",
    }
    post :create, params: { edition: { configurable_document_type: "test_type", block_content: } }
    assert_template "admin/editions/new"
    assert_select "a[href=\"#edition_test_attribute\"]", text: "Test attribute cannot be blank"
    assert_select ".govuk-error-message", text: "Error: Test attribute cannot be blank"
  end
end
