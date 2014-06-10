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

  test 'returns the policy_supporting_page path for SupportingPage instances' do
    policy = create(:policy)
    supporting_page = create(:supporting_page, related_policies: [policy])
    assert_equal policy_supporting_page_path(policy.document, supporting_page.document), public_document_path(supporting_page)
  end

  test 'returns the correct path for CorporateInformationPage instances' do
    cip = create(:corporate_information_page)
    assert_equal organisation_corporate_information_page_path(cip.organisation, cip.slug), public_document_path(cip)

    cip.corporate_information_page_type = CorporateInformationPageType::AboutUs
    assert_equal organisation_corporate_information_pages_path(cip.organisation), public_document_path(cip)

    cip.organisation.organisation_type = OrganisationType::sub_organisation
    assert_equal organisation_corporate_information_pages_path(cip.organisation), public_document_path(cip)
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

  test 'generates an appropriate path for non-English editions' do
    policy = create(:policy, locale: 'fr')
    assert_equal policy_path(policy.document, locale: 'fr'), public_document_path(policy)
  end

  test 'generates an appropriate url for non-English editions' do
    request.host = "gov.uk"
    policy = create(:policy, locale: 'fr')
    assert_equal policy_url(policy.document, host: 'gov.uk', locale: 'fr'), public_document_url(policy)
  end

  test 'When in a foreign locale, it generates a route to the foreign version if available' do
    request.host = "gov.uk"
    policy = create(:policy, :translated, translated_into: [:fr])
    I18n.with_locale(:fr) do
      assert_equal policy_url(policy.document, host: 'gov.uk', locale: 'fr'), public_document_url(policy)
    end
  end

  test 'When in a foreign locale, it generates a route to the english version if no foreign version is available' do
    request.host = "gov.uk"
    policy = create(:policy)
    I18n.with_locale(:fr) do
      assert_equal policy_url(policy.document, host: 'gov.uk', locale: 'en'), public_document_url(policy)
    end
  end

  test 'Locale is ignored if edition is a non-tranlatable type' do
    request.host = "gov.uk"
    non_translatable_edition = create(:consultation)
    refute public_document_url(non_translatable_edition, locale: 'fr').include?('fr')
  end

  test "With non-english editions, the edition's locale is always used" do
    non_english_edition = create(:world_location_news_article, locale: "fr")
    with_locale :de do
      assert public_document_url(non_english_edition, locale: 'de').include? ".fr"
    end
  end
end
