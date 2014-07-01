require 'test_helper'

class LinkCheckerTest < ActiveSupport::TestCase
  setup do
    stub_link_check(not_found, 404)
    stub_link_check(gone, 410)
    stub_link_check(success, 200)
    stub_link_check(success_2, 200)
    stub_link_check(failure, 500)
  end

  test "returns bad links" do
    checker   = LinksChecker.new([not_found, gone, success, success_2, failure], NullLogger.instance)
    broken_links = [not_found, gone, failure]
    checker.run

    assert_same_elements broken_links, checker.broken_links
  end

  test 'bad links are only reported once' do
    checker   = LinksChecker.new([not_found, not_found, success], NullLogger.instance)
    checker.run

    assert_same_elements [not_found], checker.broken_links
  end

private

  def stub_link_check(url, code)
    stub_request(:get, url).to_return(status: code, body: '')
  end

  def not_found
    'www.example.com/not_found'
  end

  def gone
    'www.example.com/gone'
   end

  def success
    'www.example.com/success'
  end

  def success_2
    'www.example.com/another_success'
  end

  def failure
    'www.example.com/failure'
  end
end
