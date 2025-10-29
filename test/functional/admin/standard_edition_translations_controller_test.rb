require "test_helper"

class Admin::StandardEditionTranslationsControllerTest < ActionController::TestCase
  setup do
    @writer = login_as(:writer)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "properties" => {
          "body" => {
            "title" => "Body (required)",
            "type" => "string",
            "format" => "govspeak",
            "tab" => "document",
          },
        },
      },
    }))
  end

  should_be_an_admin_controller

  view_test "edit indicates which language we are adding a translation for" do
    edition = create(:standard_edition, { configurable_document_type: "test_type", title: "english-title" })

    get :edit, params: { standard_edition_id: edition, id: "fr" }

    assert_select "h1", text: "Français (French) translation"
    assert_select ".govuk-caption-xl", text: "english-title"
  end

  view_test "edit presents a form to update an existing translation" do
    edition = create(:standard_edition, { configurable_document_type: "test_type", title: "english-title", block_content: { body: "english-body" } })
    with_locale(:fr) { edition.update!(title: "french-title", summary: "french-summary", block_content: { body: "french-body" }) }

    get :edit, params: { standard_edition_id: edition, id: "fr" }

    assert_select "form[action='#{@controller.admin_standard_edition_translation_path(edition, 'fr')}']" do
      assert_select "h2", text: "Translated title (required)", count: 1
      assert_select "input[type=text][name='edition[title]'][value='french-title']"
      assert_select "label", text: "Translated summary (required)"
      assert_select "textarea[name='edition[summary]']", text: "french-summary"
      assert_select "textarea[name='edition[block_content][body]']", "french-body"

      assert_select "button[type=submit]"
      assert_select "a[href=?]", @controller.admin_edition_path(edition), text: "Cancel"
    end
  end

  view_test "edit shows the primary locale value underneath the associated form fields" do
    edition = create(:standard_edition, { configurable_document_type: "test_type",
                                          title: "english-title",
                                          summary: "english-summary",
                                          block_content: {
                                            body: "test body",
                                          } })

    get :edit, params: { standard_edition_id: edition, id: "fr" }

    assert_select ".app-c-translated-input__english-translation .govuk-details__text", text: "english-title"
    assert_select ".app-c-translated-textarea__english-translation .govuk-details__text", text: "english-summary"
  end

  view_test "renders the govspeak help and history tab" do
    edition = create(:standard_edition, { configurable_document_type: "test_type", title: "english-title" })
    create(:editorial_remark, edition:)

    get :edit, params: { standard_edition_id: edition, id: "cy" }

    assert_select ".govuk-tabs__tab", text: "Help"
    assert_select ".govuk-tabs__tab", text: "History"
  end

  test "update creates a translation for an edition that's yet to be published, and redirect back to the edition admin page" do
    edition = create(:draft_standard_edition, configurable_document_type: "test_type", title: "english-title")

    put :update,
        params: { standard_edition_id: edition,
                  id: "fr",
                  edition: {
                    title: "translated-title",
                    summary: "translated-summary",
                    block_content: {
                      body: "translated-body",
                    },
                  } }

    edition.reload

    with_locale :fr do
      assert_equal "translated-title", edition.title
      assert_equal "translated-summary", edition.summary
      assert_equal "translated-body", edition.block_content["body"]
    end

    assert_redirected_to @controller.admin_standard_edition_path(edition)
  end

  test "update creates a translation for a new draft of a previously published edition" do
    published_edition = create(:published_standard_edition, configurable_document_type: "test_type", title: "english-title")
    draft_edition = published_edition.create_draft(@writer)

    put :update,
        params: { standard_edition_id: draft_edition,
                  id: "fr",
                  edition: {
                    title: "translated-title",
                    summary: "translated-summary",
                    block_content: {
                      body: "translated-body",
                    },
                  } }

    draft_edition.reload

    with_locale :fr do
      assert_equal "translated-title", draft_edition.title
      assert_equal "translated-summary", draft_edition.summary
      assert_equal "translated-body", draft_edition.block_content["body"]
    end
  end

  view_test "update renders the form again, with errors, if the translation is invalid" do
    configurable_document_type = build_configurable_document_type("test_type", "schema" => {
      "validations" => {
        "presence" => {
          "attributes" => %w[test_attribute],
        },
      },
    })
    ConfigurableDocumentType.setup_test_types(configurable_document_type)
    edition = create(:draft_standard_edition,
                     configurable_document_type: "test_type",
                     title: "english-title",
                     block_content: { "test_attribute" => "foo" })

    put :update,
        params: { standard_edition_id: edition,
                  id: "fr",
                  edition: {
                    title: "",
                    block_content: { test_attribute: "" },
                  } }

    assert_select ".govuk-error-summary"
    assert_select "a[href=\"#edition_test_attribute\"]", text: "Test attribute cannot be blank"
    assert_select ".govuk-error-message", text: "Error: Test attribute cannot be blank"
  end

  view_test "#update puts the translation to the publishing API" do
    Sidekiq::Testing.inline! do
      edition = create(:draft_standard_edition, configurable_document_type: "test_type", title: "english-title")

      put :update,
          params: { standard_edition_id: edition,
                    id: "fr",
                    edition: {
                      title: "translated-title",
                      summary: "translated-summary",
                      block_content: {
                        body: "translated-body",
                      },
                    } }

      assert_publishing_api_put_content(
        edition.content_id,
        request_json_includes(
          title: "translated-title",
          description: "translated-summary",
          details: { body: "<div class=\"govspeak\"><p>translated-body</p>\n</div>" },
          locale: "fr",
        ),
      )
    end
  end

  test "should limit access to translations of editions that aren't accessible to the current user" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "schema" => {
        "properties" => {
          "body" => {
            "title" => "Body (required)",
            "type" => "string",
            "format" => "govspeak",
          },
        },
      },
    }))
    protected_edition = create(:draft_standard_edition, :access_limited, configurable_document_type: "test_type")

    get :edit, params: { standard_edition_id: protected_edition.id, id: "en" }
    assert_response :forbidden

    put :update, params: { standard_edition_id: protected_edition.id, id: "en" }
    assert_response :forbidden
  end
end
