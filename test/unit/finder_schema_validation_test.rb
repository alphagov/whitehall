require 'test_helper'

class FinderSchemaValidationTest < ActiveSupport::TestCase
  test "the people finder is a valid finder" do
    people_finder = JSON.parse(File.read("lib/finders/people.json"))

    assert_valid_against_schema(people_finder, 'finder')
  end
end
