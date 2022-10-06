require "test_helper"

class PublicDocumentRoutesHelperTest < LocalisedUrlTestCase
  test "uses the document to generate the route" do
    publication = create(:publication)
    assert_equal publication_path(publication.document), public_document_path(publication)
  end

  test "respects additional path options" do
    publication = create(:publication)
    assert_equal publication_path(publication.document, anchor: "additional"), public_document_path(publication, anchor: "additional")
  end

  test "returns the publication_path for Publication instances" do
    publication = create(:publication)
    assert_equal publication_path(publication.document), public_document_path(publication)
  end

  test "returns the news_article_path for NewsArticle instances" do
    news_article = create(:news_article)
    assert_equal news_article_path(news_article.document), public_document_path(news_article)
  end

  test "returns the statistic_path for Publications which are Statistics or NationalStatistics" do
    statistics = create(:publication, :statistics)
    assert_equal statistic_path(statistics.document), public_document_path(statistics)
    national_statistics = create(:publication, :national_statistics)
    assert_equal statistic_path(national_statistics.document), public_document_path(national_statistics)
  end

  test "returns the speech_path for Speech instances" do
    speech = create(:speech)
    assert_equal speech_path(speech.document), public_document_path(speech)
  end

  test "returns the consultation_path for Consultation instances" do
    consultation = create(:consultation)
    assert_equal consultation_path(consultation.document), public_document_path(consultation)
  end

  test "returns the statistical_data_set_path for StatisticalDataSet instances" do
    statistical_data_set = create(:statistical_data_set)
    assert_equal statistical_data_set_path(statistical_data_set.document), public_document_path(statistical_data_set)
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

  test "returns the document URL using Whitehall public_host and protocol" do
    Whitehall.stubs(public_host: "some.host")
    Whitehall.stubs(public_protocol: "http")
    edition = create(:published_publication)
    uri = Addressable::URI.parse(public_document_url(edition))
    assert_equal "some.host", uri.host
    assert_equal "http", uri.scheme
    assert_equal public_document_path(edition), uri.path
  end

  test "generates an appropriate path for non-English editions" do
    publication = create(:publication, primary_locale: "fr")
    assert_equal publication_path(publication.document, locale: "fr"), public_document_path(publication)
  end

  test "generates an appropriate url for non-English editions" do
    publication = create(:publication, primary_locale: "fr")
    assert_equal Whitehall.url_maker.publication_url(publication.document, locale: "fr"), public_document_url(publication)
  end

  test "When in a foreign locale, it generates a route to the foreign version if available" do
    publication = create(:publication, :translated, translated_into: [:fr])
    I18n.with_locale(:fr) do
      assert_equal Whitehall.url_maker.publication_url(publication.document, locale: "fr"), public_document_url(publication)
    end
  end

  test "When in a foreign locale, it generates a route to the english version if no foreign version is available" do
    publication = create(:publication)
    I18n.with_locale(:fr) do
      assert_equal Whitehall.url_maker.publication_url(publication.document, locale: "en"), public_document_url(publication)
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
    assert_equal "http://draft-origin.test.gov.uk/government/organisations/#{edition.organisation.slug}/about/publication-scheme", preview_url
  end

  test "Creates a preview URL without parameters for edition formats that have migrated" do
    edition = create(:draft_case_study)
    preview_url = preview_document_url(edition)
    assert_equal "http://draft-origin.test.gov.uk/government/case-studies/#{edition.slug}", preview_url
  end

  test "Creates a preview URL with auth bypass token" do
    edition = create(:draft_case_study)
    token = edition.auth_bypass_token
    preview_url_with_auth_bypass_token = preview_document_url_with_auth_bypass_token(edition)
    assert_equal "http://draft-origin.test.gov.uk/government/case-studies/case-study-title?token=#{token}&utm_campaign=govuk_publishing&utm_medium=preview&utm_source=share", preview_url_with_auth_bypass_token
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

  test "append_url_options adds locale" do
    assert_equal "/government/foo.cy", append_url_options("/government/foo", locale: "cy")
  end

  test "append_url_options adds format" do
    assert_equal "/government/foo.atom", append_url_options("/government/foo", format: "atom")
  end

  test "append_url_options adds locale and format when both present" do
    assert_equal "/government/foo.cy.atom", append_url_options("/government/foo", format: "atom", locale: "cy")
  end

  test "append_url_options adds cachebust string when present" do
    assert_equal "/government/foo?cachebust=123", append_url_options("/government/foo", cachebust: "123")
  end

  test "append_url_options adds cachebust string, format and locale when all present" do
    assert_equal "/government/foo.cy.atom?cachebust=123", append_url_options("/government/foo", cachebust: "123", format: "atom", locale: "cy")
  end

  test "get_involved_path returns the path" do
    assert_equal "/government/get-involved", get_involved_path
  end

  test "get_involved_url returns the url" do
    assert_equal "https://www.test.gov.uk/government/get-involved", get_involved_url
  end

  test "get_involved_path returns the path and appends options" do
    assert_equal "/government/get-involved?cachebust=123", get_involved_path(cachebust: "123")
  end

  test "get_involved_url returns the url and appends options" do
    assert_equal "https://www.test.gov.uk/government/get-involved?cachebust=123", get_involved_url(cachebust: "123")
  end

  test "take_part_page_path returns the correct path for a slug" do
    assert_equal "/government/get-involved/take-part/foo", take_part_page_path("foo")
  end

  test "take_part_page_path returns the correct path for a slug with options" do
    assert_equal "/government/get-involved/take-part/foo?cachebust=123", take_part_page_path("foo", cachebust: "123")
  end

  test "take_part_page_path returns the correct path for a TakePart object" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "/government/get-involved/take-part/foo", take_part_page_path(object)
  end

  test "take_part_page_path returns the correct path for a TakePart object with options" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "/government/get-involved/take-part/foo?cachebust=123", take_part_page_path(object, cachebust: "123")
  end

  test "take_part_page_url returns the correct path for a slug" do
    assert_equal "https://www.test.gov.uk/government/get-involved/take-part/foo", take_part_page_url("foo")
  end

  test "take_part_page_url returns the correct path for a slug with options" do
    assert_equal "https://www.test.gov.uk/government/get-involved/take-part/foo?cachebust=123", take_part_page_url("foo", cachebust: "123")
  end

  test "take_part_page_url returns the correct path for a TakePart object" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "https://www.test.gov.uk/government/get-involved/take-part/foo", take_part_page_url(object)
  end

  test "take_part_page_url returns the correct path for a TakePart object with options" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "https://www.test.gov.uk/government/get-involved/take-part/foo?cachebust=123", take_part_page_url(object, cachebust: "123")
  end
end
