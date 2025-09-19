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

  view_test "edit shows the english values underneath the associated form fields" do
    # TODO: - this test should probably be rephrased as the "primary locale" values
    edition = create(:standard_edition, { configurable_document_type: "test_type", title: "english-title" })

    get :edit, params: { standard_edition_id: edition, id: "fr" }

    assert_select ".app-c-translated-input__english-translation .govuk-details__text", text: edition.title
    assert_select ".app-c-translated-textarea__english-translation .govuk-details__text", text: edition.summary
    assert_select ".app-c-translated-textarea__english-translation .govuk-details__text", text: edition.block_content["body"]
  end

  view_test "renders the govspeak help and history tab" do
    # TODO: confirm that fact checking is not included at the minute
    edition = create(:standard_edition, { configurable_document_type: "test_type", title: "english-title" })
    create(:editorial_remark, edition:)

    get :edit, params: { standard_edition_id: edition, id: "cy" }

    assert_select ".govuk-tabs__tab", text: "Help"
    assert_select ".govuk-tabs__tab", text: "History"
  end
end
