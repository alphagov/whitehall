require "test_helper"

class Admin::StandardEditionsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @organisation = create(:organisation)
    login_as :writer, @organisation
  end

  test "GET new with a type parameter renders correct template " do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    get :new, params: { configurable_document_type: "test_type" }

    assert_response :ok
    assert_template "admin/editions/new"
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

  view_test "GET choose_type displays all types if the group is 'all'" do
    type_one = build_configurable_document_type("type_one", { "title" => "Type One", "settings" => { "configurable_document_group" => "one" } })
    type_two = build_configurable_document_type("type_two", { "title" => "Type Two", "settings" => { "configurable_document_group" => "two" } })
    ConfigurableDocumentType.setup_test_types({}.merge(type_one, type_two))
    get :choose_type, params: { group: "all" }
    assert_response :ok
    assert_dom "h1", "New standard document"
    assert_dom "label", "Type One"
    assert_dom "label", "Type Two"
  end

  view_test "GET choose_type displays types from group" do
    type_one = build_configurable_document_type("type_one", { "title" => "Type One", "settings" => { "configurable_document_group" => "group_one" } })
    type_two = build_configurable_document_type("type_two", { "title" => "Type Two", "settings" => { "configurable_document_group" => "group_two" } })
    ConfigurableDocumentType.setup_test_types({}.merge(type_one, type_two))
    get :choose_type, params: { group: "group_two" }
    assert_response :ok
    assert_dom "h1", "New group two"
    refute_dom "label", "Type One"
    assert_dom "label", "Type Two"
  end

  view_test "GET choose_type returns a not found response when an invalid group parameter is provided" do
    get :choose_type, params: { group: "non_existent_type" }
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

  view_test "GET change_type shows error message if the edition is not in a convertable state" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    edition = create(:published_standard_edition, configurable_document_type: "test_type")
    get :change_type, params: { id: edition.id }
    assert_response :ok
    assert_dom "h1", "Cannot change document type"
    assert_dom "p", "You can only change the document type of draft, submitted or rejected editions."
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
    assert_dom "h1", "Review document type change"
  end

  view_test "PATCH apply_change_type succeeds if user has permission and params are valid" do
    original_document_type = build_configurable_document_type("original_document_type")
    new_document_type = build_configurable_document_type("new_document_type")
    ConfigurableDocumentType.setup_test_types(original_document_type.merge(new_document_type))
    edition = create(:draft_standard_edition, configurable_document_type: "original_document_type")
    StandardEdition.any_instance.stubs(:update_configurable_document_type).returns(true)

    patch :apply_change_type, params: { id: edition.id, configurable_document_type: "new_document_type" }
    assert_redirected_to admin_standard_edition_path(edition)
    assert_equal "Document type changed successfully.", flash[:notice]
  end

  view_test "PATCH apply_change_type fails if params aren't valid" do
    original_document_type = build_configurable_document_type("original_document_type")
    new_document_type = build_configurable_document_type("new_document_type")
    ConfigurableDocumentType.setup_test_types(original_document_type.merge(new_document_type))
    edition = create(:published_standard_edition, configurable_document_type: "original_document_type")
    edition.stubs(:update_configurable_document_type).returns(false)
    patch :apply_change_type, params: { id: edition.id, configurable_document_type: "new_document_type" }
    assert_redirected_to change_type_preview_admin_standard_edition_path(edition, configurable_document_type: "new_document_type")
    assert_equal "Could not change document type.", flash[:alert]
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
    configurable_document_type = build_configurable_document_type("test_type", {
      "forms" => {
        "documents" => {
          "fields" => {
            "test_attribute" => {
              "title" => "Test attribute",
              "block" => "default_string",
            },
          },
        },
      },
      "schema" => {
        "attributes" => {
          "test_attribute" => {
            "type" => "string",
          },
        },
        "validations" => {
          "presence" => {
            "attributes" => %w[test_attribute],
          },
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

  test "destroys saved new draft edition if base path conflict with published edition" do
    login_as create(:gds_admin)

    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    block_content = { "test_attribute" => "" }
    published_edition = create(:published_standard_edition)

    post :create, params: { edition: { title: published_edition.title, configurable_document_type: "test_type", block_content: } }

    assert_empty StandardEdition.draft
  end

  view_test "POST :create renders error when creating a first draft with a title that clashes with a published edition" do
    login_as create(:gds_admin)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "attributes" => {
          "body" => {
            "type" => "string",
          },
        },
      },
    }))
    published_edition = create(:published_standard_edition)

    Whitehall::PublishingApi.unstub(:check_first_draft_can_be_published_at_base_path!)
    Services.publishing_api.expects(:lookup_content_id).with(base_path: published_edition.base_path_without_sequence).returns(published_edition.content_id)
    Services.publishing_api.expects(:lookup_content_id).with(base_path: "#{published_edition.base_path}--2").returns(nil) # we also check the sequenced base path

    summary = "A valid summary"
    body = "Body content"
    patch :create, params: { edition: {
      title: published_edition.title,
      summary:,
      configurable_document_type: "test_type",
      block_content: { "body" => body },
      previously_published: false,
    } }

    assert_template "admin/editions/new"
    assert_select ".govuk-error-message", text: "Error: Title #{I18n.t('activerecord.errors.models.edition.base_path.base_path_clash')}"
    assert_equal assigns(:edition).summary, summary
    assert_equal assigns(:edition).title, published_edition.title
    assert_equal assigns(:edition).body, body
  end

  view_test "PATCH :update renders error when renaming a first draft to a title that clashes with a published edition" do
    login_as create(:gds_admin)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    published_edition = create(:published_standard_edition, title: "Title")
    new_draft_edition = create(:draft_standard_edition, title: "Another title")

    Whitehall::PublishingApi.unstub(:check_first_draft_can_be_published_at_base_path!)
    Services.publishing_api.expects(:lookup_content_id).with(base_path: published_edition.base_path).returns(published_edition.content_id)
    Services.publishing_api.expects(:lookup_content_id).with(base_path: "#{published_edition.base_path}--2").returns(nil) # we also check the sequenced base path

    patch :update, params: {
      id: new_draft_edition.id,
      edition: { title: published_edition.title, summary: new_draft_edition.summary, configurable_document_type: "test_type" },
      save: "save",
    }

    assert_template "admin/editions/edit"
    assert_select ".govuk-error-message", text: "Error: Title #{I18n.t('activerecord.errors.models.edition.base_path.base_path_clash')}"
  end
end
