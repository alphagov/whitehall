require 'test_helper'

class PublishFinderTest < ActiveSupport::TestCase
  test "it assigns a valid content id the first time it publishes the finder" do
    people_finder = JSON.parse(File.read("lib/finders/people.json"))

    publishing_api_has_lookups({})
    SecureRandom.stubs(:uuid).returns('a-content-id')
    Whitehall::FakeRummageableIndex.any_instance.expects(:add).at_least_once.with(kind_of(Hash))

    PublishFinder.call(people_finder)

    assert_publishing_api_put_content('a-content-id', people_finder)
    assert_publishing_api_publish('a-content-id', update_type: 'major')
  end

  test 'it uses the existing content id when publishing' do
    people_finder = JSON.parse(File.read("lib/finders/people.json"))

    publishing_api_has_lookups('/government/people' => 'existing-content-id')
    Whitehall::FakeRummageableIndex.any_instance.expects(:add).at_least_once.with(kind_of(Hash))

    PublishFinder.call(people_finder)

    assert_publishing_api_put_content('existing-content-id', people_finder)
    assert_publishing_api_publish('existing-content-id', update_type: 'major')
  end
end
