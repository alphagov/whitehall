require 'test_helper'
require 'sidekiq/testing'

class PublishesToPublishingApiTest < ActiveSupport::TestCase
  # publish_to_publishing_api runs on after_commit hook, so we need to disable
  # transactions for this test to allow it to run.
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.clean_with :truncation
    stub_any_publishing_api_call
  end

  teardown do
    DatabaseCleaner.clean_with :truncation
  end

  test "generating a content_id" do
    test_uuid = SecureRandom.uuid
    SecureRandom.stubs(uuid: test_uuid)
    organisation = create(:organisation)

    assert organisation.valid?
    assert_equal test_uuid, organisation.content_id
  end

  test "create publishes to Publishing API if not disallowed" do
    organisation = build(:organisation)
    Whitehall::PublishingApi.expects(:publish_async).with(organisation)
    organisation.save
  end

  test "update publishes to Publishing API if not disallowed" do
    organisation = create(:organisation)
    Whitehall::PublishingApi.expects(:publish_async).with(organisation)
    organisation.update_attribute(:name, 'Edited org')
  end

  test "create does not publish to Publishing API if disallowed" do
    organisation = build(:organisation)
    organisation.stubs(:can_publish_to_publishing_api?).returns(false)
    Whitehall::PublishingApi.expects(:publish_async).never
    organisation.save
  end

  test "update does not publish to Publishing API if disallowed" do
    organisation = create(:organisation)
    organisation.stubs(:can_publish_to_publishing_api?).returns(false)
    Whitehall::PublishingApi.expects(:publish_async).never
    organisation.update_attribute(:name, 'Edited org')
  end

  test "update publishes to Publishing API using :en locale when no translated fields are set" do
    person = create(:person, attributes_for(:person).except(:biography))

    content_item = PublishingApiPresenters.presenter_for(person).as_json
    requests = stub_publishing_api_put_content_links_and_publish(content_item)

    assert_all_requested(requests)
  end

  test "update publishes to Publishing API using :en locale when the object is not translatable" do
    policy_group = create(:policy_group)

    content_item = PublishingApiPresenters.presenter_for(policy_group).as_json
    requests = stub_publishing_api_put_content_links_and_publish(content_item)

    assert_all_requested(requests)
  end

  test "destroy publishes a Gone item to Publishing API" do
    organisation = create(:organisation)
    path = Whitehall.url_maker.polymorphic_path(organisation)
    Whitehall::PublishingApi.expects(:publish_gone).with(path)
    Whitehall::PublishingApi.expects(:publish_async).never
    organisation.destroy
  end
end
