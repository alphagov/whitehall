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
  end

  view_test "GET choose_type scopes the list of types to types that the user has permission to use" do
    configurable_document_type_user_org = build_configurable_document_type("test_type", { "schema" => { "title" => "Test Type One" }, "settings" => { "organisations" => [@current_user.organisation.content_id] } })
    configurable_document_type_other_org = build_configurable_document_type("other_type", { "schema" => { "title" => "Test Type Two" }, "settings" => { "organisations" => [SecureRandom.uuid] } })

    ConfigurableDocumentType.setup_test_types(configurable_document_type_user_org
                                                .merge(configurable_document_type_other_org))
    get :choose_type
    assert_response :ok
    assert_dom "label", "Test Type One"
    refute_dom "label", "Test Type Two"
  end

  view_test "GET edit renders default fields for a standard document" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:standard_edition)
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

    edition = build(:standard_edition)
    edition.save!

    get :edit, params: { id: edition }

    assert_response :ok
    assert_select "legend", text: "First published date"
  end

  view_test "GET edit renders the history mode form controls when history mode is enabled" do
    configurable_document_type = build_configurable_document_type("test_type", { "settings" => { "history_mode_enabled" => true } })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = build(:published_standard_edition)
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

    edition = create(:draft_standard_edition)

    login_as :managing_editor
    get :edit, params: { id: edition.id }

    assert_response :ok
    assert_select "a[href=\"#{admin_edition_attachments_path(edition)}\"]", text: "Attachments"
    assert_select "#edition_alternative_format_provider_id"
  end

  view_test "GET edit does not render the Attachments tab when file attachments are disabled" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    edition = create(:draft_standard_edition)

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
    ] })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    create(:world_location, active: true)
    edition = create(:draft_standard_edition)

    login_as :managing_editor
    get :edit, params: { id: edition.id }
    assert_response :ok
    assert_select "h2", text: "Associations"
    assert_select "label", text: "Ministers"
    assert_select "label", text: "Topical events"
    assert_select "label", text: "World locations"
  end

  test "POST create re-renders the new edition template with the submitted block content if the form is invalid" do
    configurable_document_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(configurable_document_type)

    block_content = {
      "test_attribute" => "foo",
    }
    post :create, params: { edition: { configurable_document_type: "test_type", block_content: } }
    assert_template "admin/editions/new"
  end
end
