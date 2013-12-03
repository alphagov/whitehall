# encoding: utf-8

require 'test_helper'

class LocaleTest < ActiveSupport::TestCase
  test "provides a list of all available locales" do
    I18n.stubs(:available_locales).returns([:en, :fr, :es, :ca])
    assert_equal [Locale.new(:en), Locale.new(:fr), Locale.new(:es), Locale.new(:ca)], Locale.all
  end

  test "provides a list of all available locales other than English" do
    I18n.stubs(:available_locales).returns([:en, :fr, :es, :ca])
    assert_equal [Locale.new(:fr), Locale.new(:es), Locale.new(:ca)], Locale.non_english
  end

  test "provides a list of all right-to-left locales" do
    I18n.stubs(:available_locales).returns([:en, :fr, :ar, :ca, :ur])
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
    right_to_left = [Locale.new(:ar), Locale.new(:ur), Locale.new(:fa), Locale.new(:dr), Locale.new(:he), Locale.new(:ps)]
    assert right_to_left.all?(&:rtl?)
    left_to_right = (Locale.all - right_to_left)
    assert left_to_right.none?(&:rtl?)
  end

  test "knows which locale is english" do
    assert Locale.new(:en).english?
    assert !Locale.new(:fr).english?
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
