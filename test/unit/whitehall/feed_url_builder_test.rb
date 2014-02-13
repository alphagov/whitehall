require "test_helper"

module Whitehall
  class FeedUrlBuilderTest < ActiveSupport::TestCase
    test "with :document_type as publications it generates the publications atom feed url" do
      assert_equal feed_url("publications.atom"), FeedUrlBuilder.new(document_type: 'publications').url
    end

    test "with :document_type as announcements it generates the announcements feed url" do
      assert_equal feed_url("announcements.atom"), FeedUrlBuilder.new(document_type: 'announcements').url
    end

    test "with :document_type as publications and other params it generate a publications atom feed url with the given params as query string" do
      filter_params = {
        document_type: 'publications',
        departments: ['1', '2'],
        official_document_status: "command_and_act_papers"
      }

      assert_equal feed_url("publications.atom?departments%5B%5D=1&departments%5B%5D=2&official_document_status=command_and_act_papers"),
                   Whitehall::FeedUrlBuilder.new(filter_params).url
    end

    test 'it strips blank filter params or those with a value of "all"' do
      assert_equal feed_url("publications.atom"), Whitehall::FeedUrlBuilder.new(document_type: 'publications', official_document_status: nil).url
      assert_equal feed_url("publications.atom"), Whitehall::FeedUrlBuilder.new(document_type: 'publications', official_document_status: "all").url
      assert_equal feed_url("publications.atom"), Whitehall::FeedUrlBuilder.new(document_type: 'publications', official_document_status: "").url
      assert_equal feed_url("publications.atom?official_document_status=something"),
        Whitehall::FeedUrlBuilder.new(document_type: 'publications', official_document_status: "something").url

      assert_equal feed_url("publications.atom"), Whitehall::FeedUrlBuilder.new(document_type: 'publications', departments: []).url
      assert_equal feed_url("publications.atom"), Whitehall::FeedUrlBuilder.new(document_type: 'publications', departments: ["all"]).url
      assert_equal feed_url("publications.atom"), Whitehall::FeedUrlBuilder.new(document_type: 'publications', departments: [""]).url
      assert_equal feed_url("publications.atom?departments%5B%5D=something"), Whitehall::FeedUrlBuilder.new(document_type: 'publications', departments: ["something"]).url
    end

    test "it strips out invalid filter params" do
      assert_equal feed_url("publications.atom?departments%5B%5D=something"),
        Whitehall::FeedUrlBuilder.new(document_type: 'publications', departments: ["something"], favourite_power_ranger: ["the blue one"]).url
    end

  protected

    def feed_url(url_fragment)
      "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/#{url_fragment}"
    end
  end
end
