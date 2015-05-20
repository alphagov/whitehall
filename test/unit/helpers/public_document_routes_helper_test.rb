require 'test_helper'

class PublicDocumentRoutesHelperTest < ActionView::TestCase
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

  test 'returns the statistic_path for Publications which are Statistics or NationalStatistics' do
    statistics = create(:publication, :statistics)
    assert_equal statistic_path(statistics.document), public_document_path(statistics)
    national_statistics = create(:publication, :national_statistics)
    assert_equal statistic_path(national_statistics.document), public_document_path(national_statistics)
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

  test 'returns the policy_supporting_page path for SupportingPage instances for the specified policy' do
    first_policy = create(:policy)
    second_policy = create(:policy)
    supporting_page = create(:supporting_page, related_policies: [first_policy, second_policy])
    assert_equal policy_supporting_page_path(second_policy.document, supporting_page.document), public_document_path(supporting_page, policy_id: second_policy.document)
    assert_equal policy_supporting_page_path(first_policy.document, supporting_page.document), public_document_path(supporting_page, policy_id: first_policy.document)
  end

  test 'returns the correct path for CorporateInformationPage instances' do
    cip = create(:corporate_information_page)
    assert_equal organisation_corporate_information_page_path(cip.organisation, cip.slug), public_document_path(cip)

    cip.corporate_information_page_type = CorporateInformationPageType::AboutUs
    assert_equal organisation_corporate_information_pages_path(cip.organisation), public_document_path(cip)

    cip.organisation.organisation_type = OrganisationType::sub_organisation
    assert_equal organisation_corporate_information_pages_path(cip.organisation), public_document_path(cip)
  end

  test 'returns the document URL using Whitehall public_host and protocol' do
    Whitehall.stubs(public_host: 'some.host')
    Whitehall.stubs(public_protocol: 'http')
    edition = create(:published_policy)
    uri = URI.parse(public_document_url(edition))
    assert_equal 'some.host', uri.host
    assert_equal 'http', uri.scheme
    assert_equal public_document_path(edition), uri.path
  end

  test 'generates an appropriate path for non-English editions' do
    policy = create(:policy, primary_locale: 'fr')
    assert_equal policy_path(policy.document, locale: 'fr'), public_document_path(policy)
  end

  test 'generates an appropriate url for non-English editions' do
    policy = create(:policy, primary_locale: 'fr')
    assert_equal Whitehall.url_maker.policy_url(policy.document, locale: 'fr'), public_document_url(policy)
  end

  test 'When in a foreign locale, it generates a route to the foreign version if available' do
    policy = create(:policy, :translated, translated_into: [:fr])
    I18n.with_locale(:fr) do
      assert_equal Whitehall.url_maker.policy_url(policy.document, locale: 'fr'), public_document_url(policy)
    end
  end

  test 'When in a foreign locale, it generates a route to the english version if no foreign version is available' do
    policy = create(:policy)
    I18n.with_locale(:fr) do
      assert_equal Whitehall.url_maker.policy_url(policy.document, locale: 'en'), public_document_url(policy)
    end
  end

  test 'Locale is ignored if edition is a non-tranlatable type' do
    non_translatable_edition = create(:consultation)
    refute public_document_url(non_translatable_edition, locale: 'fr').include?('fr')
  end

  test "With non-english editions, the edition's locale is always used" do
    non_english_edition = create(:world_location_news_article, primary_locale: "fr")
    with_locale :de do
      assert public_document_url(non_english_edition, locale: 'de').include? ".fr"
    end
  end

  test "organisations have the correct path generated" do
    org = create(:organisation)

    assert_equal "/government/organisations/#{org.slug}", organisation_path(org)
    assert_equal "http://test.host/government/organisations/#{org.slug}", organisation_url(org)
  end

  test "courts have the correct path generated" do
    court = create(:court)

    assert_equal "/courts-tribunals/#{court.slug}", organisation_path(court)
    assert_equal "http://test.host/courts-tribunals/#{court.slug}", organisation_url(court)
  end

  test "HMCTS tribunals have the correct path generated" do
    tribunal = create(:hmcts_tribunal)

    assert_equal "/courts-tribunals/#{tribunal.slug}", organisation_path(tribunal)
    assert_equal "http://test.host/courts-tribunals/#{tribunal.slug}", organisation_url(tribunal)
  end

  test "organisation_path still works with slugs" do
    court = create(:court)
    org = create(:organisation)

    assert_equal "/courts-tribunals/#{court.slug}", organisation_path(court.slug)
    assert_equal "/government/organisations/#{org.slug}", organisation_path(org.slug)
  end

  test "organisation_path naively uses the slug in the path if the organisation is missing" do
    assert_equal "/government/organisations/foobar", organisation_path("foobar")
    assert_equal "http://test.host/government/organisations/foobar", organisation_url("foobar")
  end
end
