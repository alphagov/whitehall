require 'test_helper'

class RummageableTest < ActiveSupport::TestCase
  def rummager_url
    'http://search.dev.gov.uk'
  end

  def index_name
    'index-name'
  end

  def documents_url(options = {})
    options[:id] ||= options[:link]

    parts = rummager_url, options.fetch(:index, index_name), 'documents'
    parts << CGI.escape(options[:type]) if options[:type]
    parts << CGI.escape(options[:id]) if options[:id]
    parts.join('/')
  end

  def link_url
    documents_url(link: link)
  end

  def status(http_code)
    {
      200 => { status: 200, body: '{"result":"OK"}' },
      502 => { status: 502, body: 'Bad gateway' }
    }.fetch(http_code)
  end

  def build_document(index)
    {
      'title' => "TITLE #{index}",
      'link' => "/link#{index}"
    }
  end

  def one_document
    build_document(1)
  end

  def two_documents
    [one_document] << build_document(2)
  end

  def link
    '/path'
  end

  def commit_url
    [rummager_url, index_name, 'commit'].join('/')
  end

  def document_url
    'http://example.com/foo'
  end

  def stub_successful_request
    stub_request(:post, documents_url).to_return(status(200))
  end

  def stub_one_failed_request
    stub_request(:post, documents_url).
      to_return(status(502)).times(1).then.to_return(status(200))
  end

  def stub_repeatedly_failing_requests(failures)
    stub_request(:post, documents_url).to_return(status(502)).times(failures)
  end

  def stub_successful_delete_request
    stub_request(:delete, documents_url(id: document_url, type: 'edition')).to_return(status(200))
  end

  def stub_one_failed_delete_request
    stub_request(:delete, documents_url(id: document_url, type: 'edition')).
      to_return(status(502)).times(1).then.to_return(status(200))
  end

  test "add should index a single document by posting it as json" do
    stub_successful_request
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.add(one_document)
    assert_requested :post, documents_url, times: 1 do |request|
      request.body == [one_document].to_json &&
        request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  test "add batch should index multiple documents in one request" do
    stub_successful_request
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.add_batch(two_documents)
    assert_requested :post, documents_url, body: two_documents.to_json
  end

  test "add batch should split large batches into multiple requests" do
    stub_successful_request
    documents = (1..3).map { |i| build_document(i) }
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, batch_size: 2)
    index.add_batch(documents)
    assert_requested :post, documents_url, body: documents[0, 2].to_json
    assert_requested :post, documents_url, body: documents[2, 1].to_json
  end

  test "add should return true when successful" do
    stub_successful_request
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    assert index.add(one_document), 'should return true on success'
  end

  test "add should sleep and retry on bad gateway errors" do
    stub_one_failed_request
    Whitehall::Rummageable::Index.any_instance.expects(:sleep).with(1)
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, retry_delay: 1)
    assert index.add(one_document), 'should return true on success'
    assert_requested :post, documents_url, times: 2
  end

  test "add should not sleep between attempts if retry delay is nil" do
    stub_one_failed_request
    Whitehall::Rummageable::Index.any_instance.expects(:sleep).never
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, retry_delay: nil)
    index.add(one_document)
    assert_requested :post, documents_url, times: 2
  end

  test "add should propagate exceptions after too many failed attempts" do
    failures = attempts = 2
    stub_repeatedly_failing_requests(failures)
    Whitehall::Rummageable::Index.any_instance.stubs(:sleep)
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, attempts: attempts)
    assert_raises RestClient::BadGateway do
      index.add(one_document)
    end
  end

  test "add should log attempts to post to rummager" do
    stub_successful_request
    logger = stub('logger', debug: true)
    logger.expects(:info).twice
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, logger: logger)
    index.add(one_document)
  end

  test "add should log failures" do
    stub_one_failed_request
    Whitehall::Rummageable::Index.any_instance.stubs(:sleep)
    logger = stub('logger', debug: true, info: true)
    logger.expects(:warn).once
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, logger: logger)
    index.add(one_document)
  end

  test "add should return unknown status for blank response" do
    RestClient.expects(:send).returns("")
    Whitehall::Rummageable::Index.any_instance.stubs(:sleep)

    logger = stub('logger', debug: true, info: true)
    logger.expects(:info).once.with(regexp_matches(/result: UNKNOWN/))

    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, logger: logger)
    index.add(one_document)
  end

  test "amend should post amendments to a document by its link" do
    new_document = { 'title' => 'Cheese', 'indexable_content' => 'Blah' }
    stub_request(:post, link_url).with(body: new_document).to_return(status(200))
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.amend(link, { 'title' => 'Cheese', 'indexable_content' => 'Blah' })
    assert_requested :post, link_url, body: new_document
  end

  test "commit should post to rummager" do
    stub_request(:post, commit_url).to_return(status(200))
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.commit
    assert_requested :post, commit_url, body: {}.to_json
  end

  test "delete should delete a document by its url" do
    stub_successful_delete_request
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.delete(document_url)
    assert_requested :delete, documents_url(id: document_url, type: 'edition') do |request|
      request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  test "delete should delete a document by its type and id" do
    stub_request(:delete, documents_url(id: 'jobs-exact', type: 'best_bet')).to_return(status(200))

    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.delete('jobs-exact', type: 'best_bet')

    assert_requested :delete, documents_url(id: 'jobs-exact', type: 'best_bet') do |request|
      request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  test "delete should be able to delete all documents" do
    stub_request(:delete, /#{documents_url}/).to_return(status(200))
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.delete_all
    assert_requested :delete, documents_url, query: { delete_all: 1 } do |request|
      request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  test "delete should handle connection errors" do
    stub_one_failed_delete_request
    Whitehall::Rummageable::Index.any_instance.expects(:sleep).once
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name)
    index.delete(document_url)
    assert_requested :delete, documents_url(id: document_url, type: 'edition'), times: 2
  end

  test "delete should log attempts to delete documents from rummager" do
    stub_successful_delete_request
    logger = stub('logger')
    logger.expects(:info).twice
    index = Whitehall::Rummageable::Index.new(rummager_url, index_name, logger: logger)
    index.delete(document_url)
  end
end
