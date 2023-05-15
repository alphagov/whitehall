require "test_helper"

class LocalesValidationTest < ActiveSupport::TestCase
  test "should validate all locale files" do
    checker = RailsTranslationManager::LocaleChecker.new("config/locales/*.yml")
    result = false
    stdout, = capture_io { result = checker.validate_locales }
    assert result, stdout
  end
end
