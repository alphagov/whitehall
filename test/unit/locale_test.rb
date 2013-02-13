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
end
