require 'test_helper'
require 'uri'

class DocumentLocaleParamCanonicalisationTest < ActionDispatch::IntegrationTest
  # we need this because locale param might be stripped by our path
  # helpers and routing, need to test what happens if it is actually
  # there
  def with_locale_param(path, locale)
    u = URI.parse(path)
    u.query = "locale=#{locale}"
    u.to_s
  end

  announcement_redir_document_types = [
    "news_article", "speech", "fatality_notice"
  ]
  normal_document_types = [
    "world_location_news_article",
    "policy", "publication", "consultation",
    "statistical_data_set", "worldwide_priority",
    "case_study"
  ]

  (announcement_redir_document_types + normal_document_types).each do |doc_type|
    test "visiting a #{doc_type} with a spurious locale=en param will redirect to remove it" do
      canonical_path = send("#{doc_type}_path", "a-#{doc_type}")
      extra_path = with_locale_param(canonical_path, 'en')
      get extra_path

      assert_redirected_to canonical_path
    end
  end

  normal_document_types.each do |doc_type|
    test "visiting the #{doc_type} index with a spurious locale=en param will redirect to remove it" do
      canonical_path = send("#{doc_type.pluralize}_path")
      extra_path = with_locale_param(canonical_path, 'en')
      get extra_path

      assert_redirected_to canonical_path
    end
  end

  # speeches, news articles and fatality notices redirect to announcements
  # index, instead of serving their own
  test 'visiting the announcements index with a spurious locale=en param will redirect to remove it' do
    canonical_path = announcements_path
    extra_path = with_locale_param(canonical_path, 'en')
    get extra_path

    assert_redirected_to canonical_path
  end

  # no index for detailed guides
  test "visiting a detailed_guide with a spurious locale=en param will redirect to remove it" do
    canonical_path = detailed_guide_path("a-detailed_guide")
    extra_path = with_locale_param(canonical_path, 'en')
    get extra_path

    assert_redirected_to canonical_path
  end
end