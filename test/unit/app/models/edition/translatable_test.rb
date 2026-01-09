require "test_helper"

class Edition::TranslatableTest < ActiveSupport::TestCase
  teardown { I18n.locale = I18n.default_locale }

  test "locale defaults to English locale key" do
    assert_equal "en", Edition.new.primary_locale
  end

  test "locale is validated as a locale" do
    edition = build(:edition, primary_locale: "123")
    assert_not edition.valid?
    assert_equal ["is not valid"], edition.errors[:primary_locale]

    edition.primary_locale = :fr
    assert edition.valid?
    edition.primary_locale = "fr"
    assert edition.valid?
  end

  test "primary_language_name returns the native English lanugage name" do
    assert_equal "English", Edition.new.primary_language_name
    assert_equal "French", Edition.new(primary_locale: :fr).primary_language_name
  end

  test "locale_can_be_changed? returns true for a StandardEdition with the translations setting enabled and no translations" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "translations_enabled" => true } }))

    assert build(:standard_edition).locale_can_be_changed?
  end

  test "locale_can_be_changed? returns true for new and existing DocumentCollections" do
    new_doc_collection = DocumentCollection.new
    existing_doc_collection = create(:document_collection)
    assert [new_doc_collection, existing_doc_collection].all?(&:locale_can_be_changed?)
  end

  test "locale_can_be_changed? returns true for new and existing Consultations" do
    new_consulation = build(:consultation)
    existing_consulation = create(:consultation)
    assert [new_consulation, existing_consulation].all?(&:locale_can_be_changed?)
  end

  test "locale_can_be_changed? returns false for other edition types" do
    Edition.concrete_descendants.reject { |k| [DocumentCollection, Consultation, CallForEvidence, StandardEdition].include?(k) }.each do |klass|
      assert_not klass.new.locale_can_be_changed?, "Instance of #{klass} should not allow the changing of primary locale"
    end
  end

  test "right-to-left editions identify themselves" do
    french_edition = create(:edition, primary_locale: :fr)
    assert_not french_edition.rtl?

    arabic_edition = create(:edition, primary_locale: :ar)
    assert arabic_edition.rtl?
  end

  test "English editions fallback to their English translation when localised" do
    edition = create(:edition, title: "English Title", body: "English Body")

    with_locale(:fr) do
      assert_equal "English Title", edition.title
      assert_equal "English Body", edition.body
      edition.title = "French Title"
      assert_equal "French Title", edition.title
      assert_equal "English Body", edition.body
    end

    assert_equal "English Title", edition.title
    assert_equal "English Body", edition.body
  end

  test "non-English editions fallback to their primary locale when localised, even with English translation" do
    I18n.locale = :fr
    french_edition = create(:edition, title: "French Title", body: "French Body", primary_locale: :fr)

    with_locale(:en) do
      french_edition.title = "English Title"
      french_edition.save!
      assert_equal "English Title", french_edition.title
    end

    I18n.locale = :es
    assert_equal "French Title", french_edition.title
    assert_equal "French Body", french_edition.body
  end

  test "updating a non-English edition does not save an empty English translation" do
    french_edition = I18n.with_locale(:fr) { create(:edition, title: "French Title", body: "French Body", primary_locale: :fr) }
    assert french_edition.available_in_locale?(:fr)
    assert_not french_edition.available_in_locale?(:en)

    force_publish(french_edition)

    assert french_edition.available_in_locale?(:fr)
    assert_not french_edition.available_in_locale?(:en)
  end

  test "changing primary locale of standard edition updates the primary locale of the translation" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = create(
      :standard_edition,
      primary_locale: "en",
    )
    edition.update!(primary_locale: "fr")

    assert edition.available_in_locale?(:fr)
    assert_not edition.available_in_locale?(:en)
  end

  test "changing primary locale of document that has lots of translations updates the primary locale of the translation but does not delete translations" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = create(
      :standard_edition,
      primary_locale: "en",
    )
    edition.translations.create!(locale: "cy")
    edition.translations.create!(locale: "fr")
    edition.update!(primary_locale: "fr")
    edition.save!

    assert_equal "fr", edition.reload.primary_locale
    assert_equal %i[en cy fr], edition.reload.translations.map(&:locale)
  end
end
