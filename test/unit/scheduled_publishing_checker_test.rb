require 'test_helper'
require 'sinatra/base'

class ScheduledPublishingCheckerTest < ActiveSupport::TestCase
  def test_success_when_published_edition_without_announcement
    FactoryBot.create(:edition, :scheduled, scheduled_publication: 1.day.ago)

    test_url = 'http://test.com/published_edition/12'
    Whitehall.url_maker.stubs(:public_document_url).returns(test_url)

    setup_server(urls: [test_url], redirects: [])

    ScheduledPublishingChecker.new.check

    assert_equal 1, MissedScheduledPublishing.count
    assert_equal ScheduledPublishingChecker::SUCCESSFULLY_PUBLISHED, MissedScheduledPublishing.last.status
  end

  def test_success_when_published_edition_with_redirected_announcement
    publication = FactoryBot.create(:publication, :statistics, :scheduled, scheduled_publication: 1.day.ago)
    FactoryBot.create(:statistics_announcement, publication: publication, release_date: 1.day.ago)

    test_url = 'http://test.com/published_edition/12'
    redirect_url = 'http://test.com/announcement/12'
    Whitehall.url_maker.stubs(:public_document_url).returns(test_url)
    Whitehall.url_maker.stubs(:statistics_announcement_path).returns(redirect_url)

    setup_server(urls: [test_url], redirects: { redirect_url => test_url })

    ScheduledPublishingChecker.new.check

    assert_equal 1, MissedScheduledPublishing.count
    assert_equal ScheduledPublishingChecker::SUCCESSFULLY_PUBLISHED, MissedScheduledPublishing.last.status
  end

  def test_error_when_published_edition_with_redirected_announcement_to_incorrect_path
    publication = FactoryBot.create(:publication, :statistics, :scheduled, scheduled_publication: 1.day.ago)
    FactoryBot.create(:statistics_announcement, publication: publication, release_date: 1.day.ago)

    test_url = 'http://test.com/published_edition/12'
    redirect_url = 'http://test.com/announcement/12'
    Whitehall.url_maker.stubs(:public_document_url).returns(test_url)
    Whitehall.url_maker.stubs(:statistics_announcement_path).returns(redirect_url)

    setup_server(urls: [test_url], redirects: { redirect_url => 'http://some.other/path' })

    ScheduledPublishingChecker.new.check

    assert_equal 1, MissedScheduledPublishing.count
    assert_equal ScheduledPublishingChecker::MISSING_REDIRECT, MissedScheduledPublishing.last.status
  end

  def test_error_when_published_edition_with_non_redirected_announcement
    publication = FactoryBot.create(:publication, :statistics, :scheduled, scheduled_publication: 1.day.ago)
    FactoryBot.create(:statistics_announcement, publication: publication, release_date: 1.day.ago)

    test_url = 'http://test.com/published_edition/12'
    redirect_url = 'http://test.com/announcement/12'
    Whitehall.url_maker.stubs(:public_document_url).returns(test_url)
    Whitehall.url_maker.stubs(:statistics_announcement_path).returns(redirect_url)

    setup_server(urls: [test_url, redirect_url], redirects: [])

    ScheduledPublishingChecker.new.check

    assert_equal 1, MissedScheduledPublishing.count
    assert_equal ScheduledPublishingChecker::MISSING_REDIRECT, MissedScheduledPublishing.last.status
  end

  def test_error_when_missing_published_edition
    FactoryBot.create(:edition, :scheduled, scheduled_publication: 1.day.ago)

    test_url = 'http://test.com/published_edition/12'
    Whitehall.url_maker.stubs(:public_document_url).returns(test_url)

    setup_server(urls: [], redirects: [])

    ScheduledPublishingChecker.new.check

    assert_equal 1, MissedScheduledPublishing.count
    assert_equal ScheduledPublishingChecker::MISSING_EDITION, MissedScheduledPublishing.last.status
  end

  def setup_server(urls:, redirects:)
    fake_server = Class.new(Sinatra::Base) do
      get '*' do
        if urls.any? { |url| url.include?(params[:splat].first) }
          body 'published document'
          status 200
        else
          _, redirection_url = redirects.detect { |url, _| url.include?(params[:splat].first) }
          if redirection_url
            body 'redirected document'
            redirect redirection_url
          else
            body 'missing document'
            halt 404
          end
        end
      end
    end

    stub_request(:any, /test.com/).to_rack(fake_server)
  end
end
