require 'test_helper'

class TextDirectionTest < ActiveSupport::TestCase
  paths = Dir[File.join(__dir__, "..", "..", "config", "locales", "*.yml")]

  paths.each do |path|
    test "explicitly sets text direction for #{File.basename(path)}" do
      data = YAML.load(File.read(path)) # rubocop:disable Security/YAMLLoad
      locale = data.keys.first

      i18n = data[locale]["i18n"]
      direction = i18n["direction"] if i18n

      assert_includes %w(ltr rtl), direction
    end
  end
end
