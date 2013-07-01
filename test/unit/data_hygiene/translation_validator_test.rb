# encoding: utf-8
require 'fast_test_helper'
require 'data_hygiene/translation_validator'
require 'tmpdir'
require 'fileutils'

require 'pp'

module DataHygiene
  class TranslationValidatorTest < ActiveSupport::TestCase
    setup do
      @translation_path = Dir.mktmpdir
      @translation_validator = TranslationValidator.new(@translation_path)
    end

    teardown do
      FileUtils.remove_entry_secure(@translation_path)
    end

    def create_translation_file(locale, content)
      File.open(File.join(@translation_path, "#{locale}.yml"), "w") do |f|
        f.write(content.lstrip)
      end
    end

    test "can create a flattened list of substitutions" do
      translation_file = YAML.load(%q{
en:
  view: View '%{title}'
  test: foo
})
      expected = [TranslationValidator::TranslationEntry.new(%w{en view}, "View '%{title}'")]
      assert_equal expected, @translation_validator.substitutions_in(translation_file)
    end

    test "detects extra substitution keys" do
      create_translation_file("en", %q{
en:
  document:
    view: View '%{title}'
})
      create_translation_file("sr", %q{
sr:
  document:
    view: Pročitajte '%{naslov}'
})
      errors = TranslationValidator.new(@translation_path).check!

      expected = %q{Key "sr.document.view": Extra substitutions: ["naslov"]. Missing substitutions: ["title"].}
      assert_equal [expected], errors.map(&:to_s)
    end
  end
end
