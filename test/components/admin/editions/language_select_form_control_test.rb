require "test_helper"
class Admin::Editions::LanguageSelectFormControlTest < ViewComponent::TestCase
  test "it does not render if translations are disabled for the edition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => false } }))
    edition = build(:draft_standard_edition)
    assert_not Admin::Editions::LanguageSelectFormControl.new(edition).render?
  end

  test "renders a select input with all available locales as options" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => true } }))
    edition = build(:draft_standard_edition)
    render_inline(Admin::Editions::LanguageSelectFormControl.new(edition))

    assert_selector "select[name=\"edition[primary_locale]\"]"
  end

  test "renders a hidden input setting the foreign language only value to true so that the editions controller doesn't ignore the primary locale" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => true } }))
    edition = build(:draft_standard_edition)
    render_inline(Admin::Editions::LanguageSelectFormControl.new(edition))
    assert_selector "input[name=\"edition[create_foreign_language_only]\"][value=\"1\"]", visible: false
  end

  test "selects English as the default language if the edition does not have a primary locale specified" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => true } }))
    edition = build(:draft_standard_edition)
    render_inline(Admin::Editions::LanguageSelectFormControl.new(edition))

    assert_selector "select[name=\"edition[primary_locale]\"] option[value=\"en\"][selected=\"selected\"]"
  end

  test "selects the edition's primary locale when one is specified" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => true } }))
    edition = build(:draft_standard_edition, primary_locale: "es")
    render_inline(Admin::Editions::LanguageSelectFormControl.new(edition))

    assert_selector "select[name=\"edition[primary_locale]\"] option[value=\"es\"][selected=\"selected\"]"
  end

  test "shows a warning that the value cannot be changed after a translation of the document has been created" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => true } }))
    edition = build(:draft_standard_edition)
    render_inline(Admin::Editions::LanguageSelectFormControl.new(edition))
    assert_selector "#edition_primary_locale_hint", text: "Warning: the language cannot be changed after this document has been translated"
  end

  test "displays the selected locale as plain text once the edition has a translation" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => true } }))
    edition = create(:draft_standard_edition)
    edition.translations.create!(locale: :fr)
    render_inline(Admin::Editions::LanguageSelectFormControl.new(edition))
    assert_selector "p", text: "English"
  end
end
