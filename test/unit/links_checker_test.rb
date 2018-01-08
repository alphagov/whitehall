require 'test_helper'

class LinkCheckerTest < ActiveSupport::TestCase
  setup do
    stub_link_check(not_found, 404)
    stub_link_check(gone, 410)
    stub_link_check(success, 200)
    stub_link_check(success_2, 200)
    stub_link_check(failed, 500)
  end

  test "returns broken links" do
    checker = LinksChecker.new([not_found, gone, success, success_2, failed], NullLogger.instance)
    broken_links = [not_found, gone, failed]
    checker.run

    assert_same_elements broken_links, checker.broken_links
  end

  test 'broken links are only reported once' do
    checker = LinksChecker.new([not_found, not_found, success], NullLogger.instance)
    checker.run

    assert_same_elements [not_found], checker.broken_links
  end

  test 'authed domains are requested with authentication' do
    begin
      current_authed_domains = LinksChecker.authed_domains
      LinksChecker.authed_domains = { 'www.requires-auth.com' => 'user:password' }
      stub_request(:get, 'www.requires-auth.com/authed_page')
        .with(basic_auth: %w(user password))
        .to_return(status: 400)

      checker = LinksChecker.new(['http://www.requires-auth.com/authed_page'], NullLogger.instance)
      checker.run

      assert_same_elements ['http://www.requires-auth.com/authed_page'], checker.broken_links
    ensure
      LinksChecker.authed_domains = current_authed_domains
    end
  end

  test 'bad URIs do not cause link checker to fall over' do
    bad_link = 'http://:wales.gov.uk/?lang=en}'
    checker = LinksChecker.new([bad_link], NullLogger.instance)
    checker.run

    assert_equal [bad_link], checker.broken_links
  end

private

  def stub_link_check(url, code)
    stub_request(:get, url).to_return(status: code, body: '')
  end

  def not_found
    'http://www.example.com/not_found'
  end

  def gone
    'http://www.example.com/gone'
   end

  def success
    'http://www.example.com/success'
  end

  def success_2
    'http://www.example.com/another_success'
  end

  def failed
    'http://www.example.com/failed'
  end
end
