require 'test_helper'

class UrlToSubscriberListCriteriaTest < ActiveSupport::TestCase
  test "can convert department to organisation" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?departments%5B%5D=advisory-committee-on-clinical-excellence-awards',
      stub("StaticData", topical_event?: false),
    )
    assert_equal converter.map_url_to_hash,
                 "links" => {
                   "organisations" => [
                     "advisory-committee-on-clinical-excellence-awards",
                   ],
                 }
  end

  test "can convert when topic is not a topical_event" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?topics%5B%5D=wildlife-and-animal-welfare',
      stub("StaticData", topical_event?: false),
    )
    assert_equal converter.map_url_to_hash,
                 "links" => {
                   "policy_areas" => [
                     "wildlife-and-animal-welfare",
                   ],
                 }
  end

  test "can convert when topic is a topical_event" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?topics%5B%5D=spending-round-2013',
      stub("StaticData", topical_event?: true),
    )
    assert_equal converter.map_url_to_hash,
                 "links" => {
                   "topical_events" => [
                     "spending-round-2013"
                   ],
                 }
  end

  test "ignores trailing whitespace" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?departments%5B%5D=advisory-committee-on-clinical-excellence-awards  ',
      stub("StaticData", topical_event?: false),
    )
    assert_equal converter.map_url_to_hash,
                 "links" => {
                   "organisations" => [
                     "advisory-committee-on-clinical-excellence-awards",
                   ],
                 }
  end

  test "can convert multiple options" do
    converter = UrlToSubscriberListCriteria.new(
      'https://www.gov.uk/government/feed?departments%5B%5D=advisory-committee-on-clinical-excellence-awards&topics%5B%5D=employment ',
      stub("StaticData", topical_event?: false),
    )
    assert_equal converter.map_url_to_hash,
                 "links" => {
                   "organisations" => [
                     "advisory-committee-on-clinical-excellence-awards",
                   ],
                   "policy_areas" => %w[
                     employment
                   ],
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

    assert_equal converter.convert, "links" => { "taxons" => ["a544d48b-1e9e-47fb-b427-7a987c658c14"] },
                                      "email_document_supertype" => "publications"
  end

  test "for now official document status gets ignored" do
    converter = UrlToSubscriberListCriteria.new(
      'http://www.dev.gov.uk/government/publications.atom?official_document_status=command_papers_only&taxons%5B%5D=a544d48b-1e9e-47fb-b427-7a987c658c14',
        stub("StaticData"),
        )

    assert_equal converter.convert,  "links" => { "taxons" => ["a544d48b-1e9e-47fb-b427-7a987c658c14"] },
                                     "email_document_supertype" => "publications"
  end
end
