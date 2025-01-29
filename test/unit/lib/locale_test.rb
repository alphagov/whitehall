require "test_helper"

class LocaleTest < ActiveSupport::TestCase
  test "provides a list of all available locale symbols" do
    Locale.stubs(:load_language_configs).returns({
      "ar" => { "direction" => "rtl" },
      "en" => { "direction" => "ltr" },
      "fr" => { "direction" => "ltr" },
      "ur" => { "direction" => "rtl" },
    })
    assert_equal %w[ar en fr ur], Locale.all_keys
  end

  test "provides a list of all available locales" do
    Locale.stubs(:load_language_configs).returns({
      "ar" => { "direction" => "rtl" },
      "en" => { "direction" => "ltr" },
      "fr" => { "direction" => "ltr" },
      "ur" => { "direction" => "rtl" },
    })
    assert_equal [Locale.new(:ar), Locale.new(:en), Locale.new(:fr), Locale.new(:ur)], Locale.all
  end

  test "provides a list of all available locales other than English" do
    Locale.stubs(:load_language_configs).returns({
      "ar" => { "direction" => "rtl" },
      "en" => { "direction" => "ltr" },
      "fr" => { "direction" => "ltr" },
      "ur" => { "direction" => "rtl" },
    })
    assert_equal [Locale.new(:ar), Locale.new(:fr), Locale.new(:ur)], Locale.non_english
  end

  test "provides a list of all right-to-left locales" do
    Locale.stubs(:load_language_configs).returns({
      "ar" => { "direction" => "rtl" },
      "en" => { "direction" => "ltr" },
      "fr" => { "direction" => "ltr" },
      "ur" => { "direction" => "rtl" },
    })
    assert_equal [Locale.new(:ar), Locale.new(:ur)], Locale.right_to_left
  end

  test "returns native language name for locale" do
    assert_equal "English", Locale.new(:en).native_language_name
    assert_equal "Español", Locale.new(:es).native_language_name
  end

  test "returns english language name for locale" do
    assert_equal "Spanish", Locale.new(:es).english_language_name
  end

  test "returns locale code for parameter form" do
    assert_equal "en", Locale.new(:en).to_param
  end

  test "knows if languages are left-to-right or right-to-left" do
    right_to_left_locale_codes = %i[ar dr fa he pa-pk ps ur yi]
    right_to_left_locales = right_to_left_locale_codes.map { |code| Locale.new(code) }
    left_to_right_locales = (Locale.all - right_to_left_locales)

    assert right_to_left_locales.all?(&:rtl?)
    assert left_to_right_locales.none?(&:rtl?)
  end

  test "knows which locale is english" do
    assert Locale.new(:en).english?
    assert_not Locale.new(:fr).english?
  end

  test "gives access to the current locale" do
    with_locale :es do
      assert_equal Locale.new(:es), Locale.current
    end

    with_locale :fr do
      assert_equal Locale.new(:fr), Locale.current
    end
  end

  test ".coerce converts a symbol into a Locale object" do
    assert_equal Locale.new(:en), Locale.coerce(:en)
  end

  test ".coerce converts a string into a Locale object" do
    assert_equal Locale.new(:en), Locale.coerce("en")
  end

  test ".coerce returns a Locale object without modification" do
    english = Locale.new(:en)
    assert_equal english, Locale.coerce(english)
  end
end
