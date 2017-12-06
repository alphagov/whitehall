require 'test_helper'

class PublishFinderTest < ActiveSupport::TestCase
  test "it assigns a valid content id the first time it publishes the finder" do
    people_finder = JSON.parse(File.read("lib/finders/people.json"))

    publishing_api_has_lookups({})
    SecureRandom.stubs(:uuid).returns('a-content-id')

    PublishFinder.call(people_finder)

    assert_publishing_api_put_content('a-content-id', people_finder)
    assert_publishing_api_publish('a-content-id')
  end

  test 'it uses the existing content id when publishing' do
    people_finder = JSON.parse(File.read("lib/finders/people.json"))

    publishing_api_has_lookups('/government/people' => 'existing-content-id')

    PublishFinder.call(people_finder)

    assert_publishing_api_put_content('existing-content-id', people_finder)
    assert_publishing_api_publish('existing-content-id')
  end
end
