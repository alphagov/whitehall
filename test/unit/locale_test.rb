# encoding: UTF-8

require 'test_helper'

class LocaleTest < ActiveSupport::TestCase
  test "returns native language name for locale" do
    assert_equal "English", Locale.new(:en).native_language_name
    assert_equal "Español", Locale.new(:es).native_language_name
  end
end
