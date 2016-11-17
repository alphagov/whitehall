require 'test_helper'

class FinderSchemaValidationTest < ActiveSupport::TestCase
  FINDER_FILES = Dir[Rails.root + "lib/finders/*.json"]

  FINDER_FILES.each do |file_path|
    name = File.basename(file_path, '.json')

    test "the #{name} finder is a valid finder" do
      finder = JSON.parse(File.read(file_path))

      assert_valid_against_schema(finder, 'finder')
    end
  end
end
