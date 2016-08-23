require 'webmock/minitest'
require 'typhoeus'
require 'plek'
require 'minitest/autorun'
require 'mocha/setup'
require_relative '../../../lib/sync_checker/request_queue'

class SyncChecker::RequestQueueTest < Minitest::Test
  def setup
    WebMock.disable!
  end

  def teardown
    WebMock.enable!
  end

  def test_draft_requests_sets_document_check_draft_when_run
    base_paths = {
      draft: {en: "/one"},
      live: {}
    }
    document_check = stub(id: 1, base_paths: base_paths)
    result_set = []
    mutex = Mutex.new
    queued_request = SyncChecker::RequestQueue.new(document_check, result_set, mutex)
    response = Typhoeus::Response.new(code: 200, body: "{'content_id', 'booyah'}")
    Typhoeus.stub("http://draft-content-store.dev.gov.uk/content/one").and_return(response)

    document_check.expects(:check_draft).with(response, :en)
    queued_request.requests.map(&:run)
  end

  def test_live_requests_sets_document_check_live_when_run
    base_paths = {
      draft: {},
      live: {en: "/one"}
    }
    document_check = stub(id: 1, base_paths: base_paths)
    result_set = []
    mutex = Mutex.new
    queued_request = SyncChecker::RequestQueue.new(document_check, result_set, mutex)
    response = Typhoeus::Response.new(code: 200, body: "{'content_id', 'booyah'}")
    Typhoeus.stub("http://content-store.dev.gov.uk/content/one").and_return(response)

    document_check.expects(:check_live).with(response, :en)
    queued_request.requests.map(&:run)
  end

  def test_adds_live_results_to_the_result_set
    base_paths = {
      draft: {},
      live: {en: "/one"}
    }
    document_check = stub(id: 1, base_paths: base_paths)
    result_set = []
    mutex = Mutex.new
    queued_request = SyncChecker::RequestQueue.new(document_check, result_set, mutex)
    response = Typhoeus::Response.new(code: 200, body: "{'content_id', 'booyah'}")
    Typhoeus.stub("http://content-store.dev.gov.uk/content/one").and_return(response)

    document_check.expects(:check_live).with(response, :en).returns(check_result = stub)
    queued_request.requests.map(&:run)

    assert_equal check_result, result_set[0]
  end

  def test_adds_draft_results_to_the_result_set
    base_paths = {
      draft: {en: "/one"},
      live: {}
    }
    document_check = stub(id: 1, base_paths: base_paths)
    result_set = []
    mutex = Mutex.new
    queued_request = SyncChecker::RequestQueue.new(document_check, result_set, mutex)
    response = Typhoeus::Response.new(code: 200, body: "{'content_id', 'booyah'}")
    Typhoeus.stub("http://draft-content-store.dev.gov.uk/content/one").and_return(response)

    document_check.expects(:check_draft).with(response, :en).returns(check_result = stub)
    queued_request.requests.map(&:run)

    assert_equal check_result, result_set[0]
  end

  def test_requests_returns_live_and_draft_requests
    base_paths = {
      draft: {en: "/one"},
      live: {en: "/two"}
    }
    document_check = stub(id: 1, base_paths: base_paths)
    result_set = []
    mutex = Mutex.new
    Typhoeus::Request.expects(:new).with(
      "http://draft-content-store.dev.gov.uk/content/one",
    ).returns(draft_request = stub(:on_complete))
    Typhoeus::Request.expects(:new).with(
      "http://content-store.dev.gov.uk/content/two",
    ).returns(live_request = stub(:on_complete))

    queued_request = SyncChecker::RequestQueue.new(document_check, result_set, mutex)

    assert queued_request.requests.include?(draft_request)
    assert queued_request.requests.include?(live_request)
    assert_equal 2, queued_request.requests.count
  end
end
