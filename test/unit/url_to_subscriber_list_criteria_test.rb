require 'test_helper'

class UrlToSubscriberListCriteriaTest < ActiveSupport::TestCase
  test "can convert department to organisation" do
    static_data = stub("StaticData")
    static_data.expects(:content_id).with('organisations', 'advisory-committee-on-clinical-excellence-awards').returns '123'
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?departments%5B%5D=advisory-committee-on-clinical-excellence-awards',
      static_data,
    )
    assert_equal converter.convert,
                 "links" => {
                   "organisations" => %w[123]
                 }
  end

  test "can convert when topic is a topical_event" do
    static_data = stub("StaticData")
    static_data.expects(:content_id).with('topical_events', 'spending-round-2013').returns '123'
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?topics%5B%5D=spending-round-2013',
      static_data,
    )
    assert_equal converter.convert,
                 "links" => {
                   "topical_events" => %w[123]
                 }
  end

  test "ignores trailing whitespace" do
    static_data = stub("StaticData")
    static_data.expects(:content_id).with('organisations', 'advisory-committee-on-clinical-excellence-awards').returns '123'
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?departments%5B%5D=advisory-committee-on-clinical-excellence-awards  ',
      static_data,
    )
    assert_equal converter.convert,
                 "links" => {
                   "organisations" => %w[123]
                 }
  end

  test "can convert multiple options" do
    static_data = stub("StaticData")
    static_data.expects(:content_id).with('organisations', 'advisory-committee-on-clinical-excellence-awards').returns '123'
    static_data.expects(:content_id).with('topical_events', 'employment').returns '456'

    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?departments%5B%5D=advisory-committee-on-clinical-excellence-awards&topics%5B%5D=employment ',
      static_data,
    )
    assert_equal converter.convert,
                 "links" => {
                   "organisations" => %w[123],
                   "topical_events" =>  %w[456]
                 }
  end

  test "will map links values to content_ids" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?departments%5B%5D=advisory-committee-on-clinical-excellence-awards',
      stub("StaticData", topical_event?: false, content_id: 'aaaaa'),
    )
    assert_equal converter.convert, "links" => { "organisations" => %w[aaaaa] }
  end

  test "can extract `email_document_supertype` and `government_document_supertype` from announcement url" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/announcements.atom?announcement_filter_option=news-stories',
      stub("StaticData"),
    )
    assert_equal converter.convert,
                 "links" => {},
                 "email_document_supertype" => "announcements",
                 "government_document_supertype" => "news-stories"
  end

  test "can extract email `email_document_supertype` and `government_document_supertype` from publication url" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/publications.atom?publication_filter_option=transparency-data',
      stub("StaticData"),
    )

    assert_equal converter.convert,
                 "links" => {},
                 "email_document_supertype" => "publications",
                 "government_document_supertype" => "transparency-data"
  end

  test "can extract `email_document_supertype` and `government_document_supertype` from statistics url" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/statistics.atom',
      stub("StaticData"),
    )

    assert_equal converter.convert,
                 "links" => {},
                 "email_document_supertype" => "publications",
                 "government_document_supertype" => "statistics"
  end

  test "It converts URLs containing taxons" do
    converter = UrlToSubscriberListCriteria.new(
      'http://www.dev.gov.uk/government/publications.atom?taxons%5B%5D=a544d48b-1e9e-47fb-b427-7a987c658c14',
        stub("StaticData"),
        )

    assert_equal converter.convert, "links" => { "taxon_tree" => ["a544d48b-1e9e-47fb-b427-7a987c658c14"] },
                                      "email_document_supertype" => "publications"
  end

  test "for now official document status gets ignored" do
    converter = UrlToSubscriberListCriteria.new(
      'http://www.dev.gov.uk/government/publications.atom?official_document_status=command_papers_only&taxons%5B%5D=a544d48b-1e9e-47fb-b427-7a987c658c14',
        stub("StaticData"),
        )

    assert_equal converter.convert,  "links" => { "taxon_tree" => ["a544d48b-1e9e-47fb-b427-7a987c658c14"] },
                                     "email_document_supertype" => "publications"
  end
end
