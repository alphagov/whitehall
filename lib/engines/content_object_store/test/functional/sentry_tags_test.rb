require "test_helper"
require "sentry/test_helper"

class ContentObjectStore::SentryTagsTest < ActionController::TestCase
  tests ContentObjectStore::ContentBlock::DocumentsController
  include Sentry::TestHelper

  setup do
    initialize_engine_routes
    setup_sentry_test
    feature_flags.switch!(:content_object_store, true)
    login_as_admin
  end

  teardown do
    teardown_sentry_test
  end

  test "throwing an error includes tags" do
    exception = ArgumentError.new("Some error")
    raises_exception = ->(*_args) { raise exception }

    ContentObjectStore::ContentBlock::Document.stub :all, raises_exception do
      get :index
    rescue ArgumentError => e
      Sentry.capture_exception(e)
    end

    assert_equal 1, sentry_events.count
    assert_equal "content_object_store", sentry_events[0].tags[:engine]
  end

private

  def initialize_engine_routes
    @routes = ContentObjectStore::Engine.routes
  end
end
