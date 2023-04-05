require "test_helper"

class PublicDocumentRoutesHelperTest < LocalisedUrlTestCase
  test "uses the document to generate the route" do
    publication = create(:publication)
    assert_equal publication.public_path, public_document_path(publication)
  end

  test "respects additional path options" do
    publication = create(:publication)
    assert_equal publication.public_path(anchor: "additional"), public_document_path(publication, anchor: "additional")
  end

  test "returns the public_path for Publication instances" do
    publication = create(:publication)
    assert_equal publication.public_path, public_document_path(publication)
  end

  test "returns the public_path for NewsArticle instances" do
    news_article = create(:news_article)
    assert_equal news_article.public_path, public_document_path(news_article)
  end

  test "returns the public_path for Publications which are Statistics or NationalStatistics" do
    statistics = create(:publication, :statistics)
    assert_equal statistics.public_path, public_document_path(statistics)
    national_statistics = create(:publication, :national_statistics)
    assert_equal national_statistics.public_path, public_document_path(national_statistics)
  end

  test "returns the public_path for Speech instances" do
    speech = create(:speech)
    assert_equal speech.public_path, public_document_path(speech)
  end

  test "returns the public_path for Consultation instances" do
    consultation = create(:consultation)
    assert_equal consultation.public_path, public_document_path(consultation)
  end

  test "returns the statistical_data_set_path for StatisticalDataSet instances" do
    statistical_data_set = create(:statistical_data_set)
    assert_equal statistical_data_set.public_path, public_document_path(statistical_data_set)
  end

  test "returns the correct path for CorporateInformationPage for organisations" do
    org = create(:organisation)
    cip = create(:corporate_information_page, organisation: org, translated_into: [:fr])

    cip.corporate_information_page_type = CorporateInformationPageType::Research
    assert_equal "/government/organisations/#{org.slug}/about/research", public_document_path(cip)
    assert_equal "/government/organisations/#{org.slug}/about/research.fr", public_document_path(cip, locale: :fr)

    cip.corporate_information_page_type = CorporateInformationPageType::AboutUs
    assert_equal "/government/organisations/#{org.slug}/about", public_document_path(cip)
    assert_equal "/government/organisations/#{org.slug}/about.fr", public_document_path(cip, locale: :fr)

    cip.organisation.organisation_type = OrganisationType.sub_organisation
    assert_equal "/government/organisations/#{org.slug}/about", public_document_path(cip)
    assert_equal "/government/organisations/#{org.slug}/about.fr", public_document_path(cip, locale: :fr)
  end

  test "returns the correct path for CorporateInformationPage for worldwide organisations" do
    org = create(:worldwide_organisation)
    cip = create(:corporate_information_page, organisation: nil, worldwide_organisation: org, translated_into: [:fr])

    cip.corporate_information_page_type = CorporateInformationPageType::Research
    assert_equal "/world/organisations/#{org.slug}/about/research", public_document_path(cip)
    assert_equal "/world/organisations/#{org.slug}/about/research.fr", public_document_path(cip, locale: :fr)

    cip.corporate_information_page_type = CorporateInformationPageType::AboutUs
    assert_equal "/world/organisations/#{org.slug}", public_document_path(cip)
    assert_equal "/world/organisations/#{org.slug}.fr", public_document_path(cip, locale: :fr)
  end

  test "returns the document URL always using the correct public site URL and protocol" do
    edition = create(:published_publication)
    uri = Addressable::URI.parse(public_document_url(edition))
    assert_equal "www.test.gov.uk", uri.host
    assert_equal "https", uri.scheme
    assert_equal public_document_path(edition), uri.path
  end

  test "generates an appropriate path for non-English editions" do
    publication = create(:publication, primary_locale: "fr")
    assert_equal publication.public_path(locale: "fr"), public_document_path(publication)
  end

  test "generates an appropriate url for non-English editions" do
    publication = create(:publication, primary_locale: "fr")
    assert_equal publication.public_url(locale: "fr"), public_document_url(publication)
  end

  test "When in a foreign locale, it generates a route to the foreign version if available" do
    publication = create(:publication, :translated, translated_into: [:fr])
    I18n.with_locale(:fr) do
      assert_equal publication.public_url(locale: "fr"), public_document_url(publication)
    end
  end

  test "When in a foreign locale, it generates a route to the english version if no foreign version is available" do
    publication = create(:publication)
    I18n.with_locale(:fr) do
      assert_equal publication.public_url, public_document_url(publication)
    end
  end

  test "Locale is ignored if edition is a non-translatable type" do
    non_translatable_edition = create(:consultation)
    assert_not public_document_url(non_translatable_edition, locale: "fr").include?("fr")
  end

  test "With non-english editions, the edition's locale is always used" do
    non_english_edition = create(:news_article_world_news_story, primary_locale: "fr")
    with_locale :de do
      assert public_document_url(non_english_edition, locale: "de").include? ".fr"
    end
  end

  test "Creates a preview URL with cachebust and edition parameters" do
    edition = create(:corporate_information_page)
    preview_url = preview_document_url(edition)
    assert_equal "https://draft-origin.test.gov.uk/government/organisations/#{edition.organisation.slug}/about/publication-scheme", preview_url
  end

  test "Creates a preview URL without parameters for edition formats that have migrated" do
    edition = create(:draft_case_study)
    preview_url = preview_document_url(edition)
    assert_equal "https://draft-origin.test.gov.uk/government/case-studies/#{edition.slug}", preview_url
  end

  test "Creates a preview URL with auth bypass token" do
    edition = create(:draft_case_study)
    token = edition.auth_bypass_token
    preview_url_with_auth_bypass_token = preview_document_url_with_auth_bypass_token(edition)
    assert_equal "https://draft-origin.test.gov.uk/government/case-studies/case-study-title?token=#{token}&utm_campaign=govuk_publishing&utm_medium=preview&utm_source=share", preview_url_with_auth_bypass_token
  end
end
