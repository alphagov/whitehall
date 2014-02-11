require "test_helper"

module Whitehall
  class FeedUrlBuilderTest < ActiveSupport::TestCase
    test "With no params, it should generate a generic feed url" do
      assert_equal feed_url("feed"), FeedUrlBuilder.new.url
    end

    test "With document_type as publications, it should generate publications feed url" do
      assert_equal feed_url("publications.atom"), FeedUrlBuilder.new(document_type: 'publications').url
    end

    test "With document_type as announcements, it should generate announcements feed url" do
      assert_equal feed_url("announcements.atom"), FeedUrlBuilder.new(document_type: 'announcements').url
    end

    test "With document_type as publications with some other params, it should generate a publications feed url with the given params as query string" do
      filter_params = {
        document_type: 'publications',
        departments: ['1', '2'],
        official_document_status: "command_and_act_papers"
      }

      assert_equal feed_url("publications.atom?departments%5B%5D=1&departments%5B%5D=2&official_document_status=command_and_act_papers"),
                   Whitehall::FeedUrlBuilder.new(filter_params).url
    end

    test "It strips blank params or params with the value of all" do
      assert_equal feed_url("feed"), Whitehall::FeedUrlBuilder.new(official_document_status: nil).url
      assert_equal feed_url("feed"), Whitehall::FeedUrlBuilder.new(official_document_status: "all").url
      assert_equal feed_url("feed"), Whitehall::FeedUrlBuilder.new(official_document_status: "").url
      assert_equal feed_url("feed?official_document_status=something"), Whitehall::FeedUrlBuilder.new(official_document_status: "something").url

      assert_equal feed_url("feed"), Whitehall::FeedUrlBuilder.new(departments: []).url
      assert_equal feed_url("feed"), Whitehall::FeedUrlBuilder.new(departments: ["all"]).url
      assert_equal feed_url("feed"), Whitehall::FeedUrlBuilder.new(departments: [""]).url
      assert_equal feed_url("feed?departments%5B%5D=something"), Whitehall::FeedUrlBuilder.new(departments: ["something"]).url
    end

    test "It should only accept the right params for generic feeds" do
      assert_equal feed_url("feed?departments%5B%5D=something"), Whitehall::FeedUrlBuilder.new(departments: ["something"], favourite_power_ranger: ["the blue one"]).url
    end

  protected

    def feed_url(url_fragment)
      "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/#{url_fragment}"
    end
  end
end
