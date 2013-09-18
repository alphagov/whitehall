# encoding: UTF-8
require 'test_helper'

class TranslationHelperTest < ActionView::TestCase
  setup do
    @document = stub('document', display_type_key: 'stub')
  end

  test "#t_display_type translates document display type" do
    I18n.backend.store_translations :en, {document: {type: {stub: {one: 'Stub'}}}}
    assert_equal "Stub", t_display_type(@document)
  end

  test "sorted_locales returns default locale first" do
    assert_equal I18n.default_locale, sorted_locales([:fr, :es, I18n.default_locale, :de]).first
  end

  test "sorted_locales returns other locals in alphabetically locale code order" do
    assert_equal [:de, :es, :fr], sorted_locales([:fr, :es, I18n.default_locale, :de])[1..-1]
  end

  test "sorted_locales copes with the default locale not being present" do
    assert_equal [:de, :es, :fr], sorted_locales([:fr, :de, :es])
  end

  test "t_delivery_title returns translation of 'Minister' if document was delivered by minister" do
    I18n.with_locale(:fr) do
      assert_equal "Ministre", t_delivery_title(stub('document', speech_type: stub('type', owner_key_group: 'delivery_title'), delivered_by_minister?: true))
    end
  end

  test "t_delivery_title returns translation of 'Speaker' if document was not delivered by minister" do
    I18n.with_locale(:fr) do
      assert_equal "Orateur", t_delivery_title(stub('document', speech_type: stub('type', owner_key_group: 'delivery_title'), delivered_by_minister?: false))
    end
  end

  test "t_corporate_information_page_type tranlsates the type of corporate informaton page" do
    I18n.with_locale(:fr) do
      assert_equal "Charte de données personnelles", t_corporate_information_page_type(stub('corp info page', display_type_key: "personal_information_charter"))
    end
  end

  test "t_delivered_on returns appropriate translation depending on whether speech was written or delivered" do
    I18n.with_locale(:fr) do
      assert_match /Prononcé le/, t_delivered_on(stub('speech_type', published_externally_key: 'delivered_on'))
      assert_match /Ecrit le/, t_delivered_on(stub('speech_type', published_externally_key: 'written_on'))
    end
  end
end
