require "test_helper"
require "sentry/test_helper"

class ContentObjectStore::SentryTagsTest < ActionDispatch::IntegrationTest
  include Sentry::TestHelper

  setup do
    setup_sentry_test
    feature_flags.switch!(:content_object_store, true)
    login_as_admin
  end

  teardown do
    teardown_sentry_test
  end

  test "throwing an error includes tags" do
    exception = ArgumentError.new("Cannot find schema for block_type")
    raises_exception = ->(*_args) { raise exception }

    ContentObjectStore::ContentBlock::Document.stub :all, raises_exception do
      get content_object_store.content_object_store_content_block_documents_path
    rescue ArgumentError
      assert_equal sentry_events.count, 1
      assert_equal sentry_events[0].tags[:engine], "content_object_store"
    end
  end
end
