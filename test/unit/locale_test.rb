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
    right_to_left = [Locale.new(:ar), Locale.new(:ur), Locale.new(:fa), Locale.new(:dr)]
    assert right_to_left.all?(&:rtl?)
    assert (Locale.all - right_to_left).none?(&:rtl?)
  end
end
