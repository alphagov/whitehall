require "test_helper"

class TranslationHelperTest < ActionView::TestCase
  include TranslatableModel

  setup do
    @document = stub("document", display_type_key: "stub")
    @model = stub("model")
    @model.extend(TranslatableModel)
  end

  teardown do
    I18n.backend.reload!
  end

  test "#t_display_type translates document display type" do
    I18n.backend.store_translations :en, document: { type: { stub: { one: "Stub" } } }
    assert_equal "Stub", t_display_type(@document)
  end

  test "sorted_locales returns default locale first" do
    assert_equal I18n.default_locale, sorted_locales([:fr, :es, I18n.default_locale, :de]).first
  end

  test "sorted_locales returns other locals in alphabetically locale code order" do
    assert_equal %i[de es fr], sorted_locales([:fr, :es, I18n.default_locale, :de])[1..]
  end

  test "sorted_locales copes with the default locale not being present" do
    assert_equal %i[de es fr], sorted_locales(%i[fr de es])
  end

  test "t_delivery_title returns translation of 'Minister' if document was delivered by minister" do
    I18n.with_locale(:fr) do
      assert_equal "Ministre", t_delivery_title(stub("document", speech_type: stub("type", owner_key_group: "delivery_title"), delivered_by_minister?: true))
    end
  end

  test "t_delivery_title returns translation of 'Speaker' if document was not delivered by minister" do
    I18n.with_locale(:fr) do
      assert_equal "Orateur", t_delivery_title(stub("document", speech_type: stub("type", owner_key_group: "delivery_title"), delivered_by_minister?: false))
    end
  end

  test "t_corporate_information_page_link_text uses the type translation for the type of corporate information page if the link_text translation is not available" do
    I18n.backend.store_translations :en,
                                    corporate_information_page: {
                                      type: {
                                        title: {
                                          where_we_get_our_wonderful_hats: "Where do we get our wonderful hats?",
                                        },
                                      },
                                    }
    I18n.with_locale(:en) do
      assert_equal "Where do we get our wonderful hats?", t_corporate_information_page_type_link_text(stub("corp info page", display_type_key: "where_we_get_our_wonderful_hats"))
    end
  end

  test "t_corporate_information_page_link_text uses the link_text translation for the type of corporate information page if available" do
    I18n.backend.store_translations :en,
                                    corporate_information_page: {
                                      type: {
                                        title: {
                                          where_we_get_our_wonderful_hats: "Where do we get our wonderful hats?",
                                        },
                                        link_text: {
                                          where_we_get_our_wonderful_hats: "Oh my! What a hat!",
                                        },
                                      },
                                    }
    I18n.with_locale(:en) do
      assert_equal "Oh my! What a hat!", t_corporate_information_page_type_link_text(stub("corp info page", display_type_key: "where_we_get_our_wonderful_hats"))
    end
  end

  test "t_delivered_on returns appropriate translation depending on whether speech was written or delivered" do
    I18n.with_locale(:fr) do
      assert_match %r{Livré le :}, t_delivered_on(stub("speech_type", published_externally_key: "delivered_on"))
      assert_match %r{Rédiger le :}, t_delivered_on(stub("speech_type", published_externally_key: "written_on"))
    end
  end

  test "t_fallback returns false if string is translated successfully" do
    I18n.backend.store_translations :en, document: { one: "string" }
    I18n.with_locale(:en) do
      assert_equal false, t_fallback("document.one", {})
    end
  end

  test "t_fallback returns default locale if translated string is nil" do
    I18n.with_locale(:de) do
      assert_equal :en, t_fallback("testing.nil", {})
    end
  end

  test "t_fallback returns default locale if translated string uses fallback" do
    I18n.default_locale = :en
    I18n.backend.store_translations :en, document: { one: "string" }

    I18n.with_locale(:de) do
      assert_equal :en, t_fallback("document.one", {})
    end
  end

  test "t_fallback returns default locale if translated string hash is all nil" do
    I18n.default_locale = :en

    I18n.with_locale(:de) do
      I18n.backend.store_translations :de, testing: { test: { one: nil, other: nil } }
      assert_equal :en, t_fallback("testing.test", count: 2)
    end
  end

  test "t_lang returns nil if the translated string matches the current locale" do
    I18n.backend.store_translations :en, document: { one: "string" }
    I18n.with_locale(:en) do
      assert_nil t_lang("document.one")
    end
  end

  test "t_lang returns lang attribute if translated string does not match current locale" do
    I18n.backend.store_translations :en, document: { one: "string" }

    I18n.with_locale(:de) do
      assert_equal "lang=en", t_lang("document.one")
    end
  end
end
