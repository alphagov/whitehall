require 'test_helper'

class PublicDocumentRoutesHelperTest < ActionView::TestCase
  setup do
    @request  = ActionController::TestRequest.new
    ActionController::Base.default_url_options = {}
  end
  attr_reader :request

  test 'uses the document to generate the route' do
    policy = create(:policy)
    assert_equal policy_path(policy.document), public_document_path(policy)
  end

  test 'respects additional path options' do
    policy = create(:policy)
    assert_equal policy_path(policy.document, anchor: 'additional'), public_document_path(policy, anchor: 'additional')
  end

  test 'returns the policy_path for Policy instances' do
    policy = create(:policy)
    assert_equal policy_path(policy.document), public_document_path(policy)
  end

  test 'returns the publication_path for Publication instances' do
    publication = create(:publication)
    assert_equal publication_path(publication.document), public_document_path(publication)
  end

  test 'returns the news_article_path for NewsArticle instances' do
    news_article = create(:news_article)
    assert_equal news_article_path(news_article.document), public_document_path(news_article)
  end

  test 'returns the speech_path for Speech instances' do
    speech = create(:speech)
    assert_equal speech_path(speech.document), public_document_path(speech)
  end

  test 'returns the consultation_path for Consultation instances' do
    consultation = create(:consultation)
    assert_equal consultation_path(consultation.document), public_document_path(consultation)
  end

  test 'returns the statistical_data_set_path for StatisticalDataSet instances' do
    statistical_data_set = create(:statistical_data_set)
    assert_equal statistical_data_set_path(statistical_data_set.document), public_document_path(statistical_data_set)
  end

  test 'uses the document to generate the supporting page route' do
    policy = create(:policy)
    supporting_page = create(:supporting_page, edition: policy)
    assert_equal policy_supporting_page_path(policy.document, supporting_page), public_supporting_page_path(policy, supporting_page)
  end

  test 'returns public document URL including host in production environment' do
    request.host = "whitehall.production.alphagov.co.uk"
    edition = create(:published_policy)
    assert_equal "www.gov.uk", URI.parse(public_document_url(edition)).host
  end

  test 'returns public document URL including host in public production environment' do
    request.host = "www.gov.uk"
    edition = create(:published_policy)
    assert_equal "www.gov.uk", URI.parse(public_document_url(edition)).host
  end

  test 'returns public supporting page URL including host in production environment' do
    request.host = "whitehall.production.alphagov.co.uk"
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    assert_equal "www.gov.uk", URI.parse(public_supporting_page_url(edition, supporting_page)).host
  end

  test 'returns public supporting page URL including host in public production environment' do
    request.host = "www.gov.uk"
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    assert_equal "www.gov.uk", URI.parse(public_supporting_page_url(edition, supporting_page)).host
  end

  test 'returns public document URL including host in preview environment' do
    request.host = "whitehall.preview.alphagov.co.uk"
    edition = create(:published_policy)
    assert_equal "www.preview.alphagov.co.uk", URI.parse(public_document_url(edition)).host
  end

  test 'returns public document URL including host in public preview environment' do
    request.host = "www.preview.alphagov.co.uk"
    edition = create(:published_policy)
    assert_equal "www.preview.alphagov.co.uk", URI.parse(public_document_url(edition)).host
  end

  test 'returns public supporting page URL including host in preview environment' do
    request.host = "whitehall.preview.alphagov.co.uk"
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    assert_equal "www.preview.alphagov.co.uk", URI.parse(public_supporting_page_url(edition, supporting_page)).host
  end

  test 'returns public supporting page URL including host in public preview environment' do
    request.host = "www.preview.alphagov.co.uk"
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    assert_equal "www.preview.alphagov.co.uk", URI.parse(public_supporting_page_url(edition, supporting_page)).host
  end

  test 'returns public URL including host in preview admin environment' do
    request.host = 'whitehall-admin.preview.alphagov.co.uk'
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    assert_equal "www.preview.alphagov.co.uk", URI.parse(public_supporting_page_url(edition, supporting_page)).host
  end

  test 'returns public URL including host in production admin environment' do
    request.host = 'whitehall-admin.production.alphagov.co.uk'
    edition = create(:published_policy)
    supporting_page = create(:supporting_page, edition: edition)
    assert_equal "www.gov.uk", URI.parse(public_supporting_page_url(edition, supporting_page)).host
  end

  test 'generates an appropriate path for non-English editions' do
    policy = create(:policy, locale: 'fr')
    assert_equal policy_path(policy.document, locale: 'fr'), public_document_path(policy)
  end

  test 'generates an appropriate url for non-English editions' do
    request.host = "gov.uk"
    policy = create(:policy, locale: 'fr')
    assert_equal policy_url(policy.document, host: 'gov.uk', locale: 'fr'), public_document_url(policy)
  end

  test 'generates a preview path for publication html versions' do
    publication = create(:publication)
    html_version = publication.html_version

    expected_path = "/government/publications/#{publication.slug}/#{html_version.slug}?cachebust=1321009871&preview=#{html_version.id}"
    assert_equal expected_path, preview_html_version_path(publication, html_version)
  end

    test 'generates a preview path for consultation html versions' do
    consultation = create(:consultation, html_version: create(:html_version))
    html_version = consultation.html_version

    expected_path = "/government/consultations/#{consultation.slug}/#{html_version.slug}?cachebust=1321009871&preview=#{html_version.id}"
    assert_equal expected_path, preview_html_version_path(consultation, html_version)
  end
end
