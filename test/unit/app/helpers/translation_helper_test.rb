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
