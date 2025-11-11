# frozen_string_literal: true

require "test_helper"

class Admin::Editions::Show::TranslationsTest < ViewComponent::TestCase
  NonTranslatableEdition = Class.new(Edition) do
    def translatable
      false
    end
  end

  TranslatableEdition = Class.new(Edition) do
    include Edition::Translatable
    def translatable?
      true
    end
  end

  test "it does not render if the edition is not translatable" do
    edition = NonTranslatableEdition.new
    render_inline(Admin::Editions::Show::Translations.new(edition))
    assert page.text.blank?
  end

  test "it renders the language for each translation except the primary locale" do
    edition = TranslatableEdition.new(id: 1, primary_locale: "fr")
    edition.translations.build(locale: "fr")
    edition.translations.build(locale: "de")
    edition.translations.build(locale: "es")
    render_inline(Admin::Editions::Show::Translations.new(edition))

    assert page.has_content? "Deutsch (German)"
    assert page.has_content? "Español (Spanish)"
    assert_not page.has_content? "Français (French)"
  end
end
