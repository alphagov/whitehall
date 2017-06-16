require "test_helper"

class DocumentListExportPresenterTest < ActiveSupport::TestCase
  test '#sub_content_type returns the correct subtype for news articles' do
    article = build(:news_article, news_article_type: NewsArticleType::PressRelease)
    pr = DocumentListExportPresenter.new(article)
    assert_equal 'Press release', pr.sub_content_type
  end

  test '#sub_content_type returns the correct subtype for publications' do
    pub = build(:publication, publication_type: PublicationType::Guidance)
    pr = DocumentListExportPresenter.new(pub)
    assert_equal 'Guidance', pr.sub_content_type
  end

  test '#sub_content_type returns the correct subtype for corporate information pages' do
    cip = build(:corporate_information_page, corporate_information_page_type: CorporateInformationPageType::AboutUs, organisation: nil)
    pr = DocumentListExportPresenter.new(cip)
    assert_equal 'About', pr.sub_content_type
  end

  test '#sub_content_type returns N/A for types without subtype' do
    guide = build(:detailed_guide)
    pr = DocumentListExportPresenter.new(guide)
    assert_equal 'N/A', pr.sub_content_type
  end

  test '#attachment_types returns details of each attachment' do
    file_attachment = build(:file_attachment)
    html_attachment = build(:html_attachment, title: 'An HTML attachment')
    external_attachment = build(:external_attachment, external_url: 'http://www.example.com')
    pub = build(:publication, attachments: [file_attachment, html_attachment, external_attachment])

    pr = DocumentListExportPresenter.new(pub)
    assert_equal(['greenpaper.pdf', 'An HTML attachment', 'http://www.example.com'], pr.attachment_types)
  end

  test '#format_elements formats arrays, dates and booleans but leaves strings alone' do
    pr = DocumentListExportPresenter.new('')
    data = [%w(list of elements), Time.new(2014, 10, 5, 10, 15), 'normal string', true, false]
    assert_equal(['list | of | elements', '2014-10-05 10:15:00', 'normal string', 'yes', 'no',], pr.format_elements(data))
  end

  test '#lead_organisations returns list of lead org names' do
    org1 = build(:organisation, name: "Org 1")
    org2 = build(:organisation, name: "Org 2")
    publication = build(:publication)
    publication.stubs(:lead_organisations).returns([org1, org2])
    pr = DocumentListExportPresenter.new(publication)
    assert_equal(['Org 1', 'Org 2'], pr.lead_organisations)
  end

  test '#lead_organisations returns owning org for Corporate Info pages' do
    org1 = build(:organisation, name: "Org 1")
    cip = build(:corporate_information_page, organisation: org1)
    pr = DocumentListExportPresenter.new(cip)
    assert_equal('Org 1', pr.lead_organisations)
  end

  test '#policies returns a list of the related policies' do
    news = create(:news_article, policy_content_ids: [policy_1['content_id']])
    pr = DocumentListExportPresenter.new(news)
    assert_equal [policy_area_1['title'], policy_1['title']], pr.policies
  end

  test '#state returns `force published` when a document is force published' do
    publication = create(:published_publication, force_published: true)

    pub = DocumentListExportPresenter.new(publication)
    assert_equal "force published", pub.state
  end

  test '#state returns `unpublished` when a document is unpublished' do
    unpublished_edition = create(:edition, :unpublished)

    presenter = DocumentListExportPresenter.new(unpublished_edition)
    assert_equal "unpublished", presenter.state
  end

  test '#primary_language returns the language of the main edition' do
    french_edition = create(:edition, primary_locale: 'fr')
    presenter = DocumentListExportPresenter.new(french_edition)
    assert_equal 'French', presenter.primary_language
  end

  test '#translations_available returns "none" when a document is only available in english' do
    edition = create(:edition)
    presenter = DocumentListExportPresenter.new(edition)
    assert_equal 'none', presenter.translations_available
  end

  test '#translations_available returns "none" when a document is only available in a foreign language' do
    french_edition = with_locale(:fr) { create(:edition, primary_locale: 'fr') }
    presenter = DocumentListExportPresenter.new(french_edition)
    assert_equal 'none', presenter.translations_available
  end

  test '#translations_available returns the language name of a documents translation' do
    edition_also_available_in_welsh = create(:edition, :translated, primary_locale: 'en', translated_into: 'cy')
    presenter = DocumentListExportPresenter.new(edition_also_available_in_welsh)
    assert_equal %w(Welsh), presenter.translations_available
  end

  test '#translations_available returns a list of all the language names of a documents translation, sorted by language code' do
    edition_translated_many_times = create(:edition, :translated, primary_locale: 'en', translated_into: %w(ms ar cy))
    presenter = DocumentListExportPresenter.new(edition_translated_many_times)
    assert_equal %w(Arabic Welsh Malay), presenter.translations_available
  end
end
