require "test_helper"

class DocumentListExportPresenterTest < ActiveSupport::TestCase
  include ContentRegisterHelpers

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
    assert_equal(['list, of, elements', '2014-10-05 10:15:00', 'normal string', 'yes', 'no',], pr.format_elements(data))
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
    policy = create(:policy)
    news   = create(:news_article, related_documents: [policy.document])
    pr = DocumentListExportPresenter.new(news)
    assert_equal [policy.title], pr.policies
  end

  test '#policies returns policy titles with future-policies flag on' do
    stub_content_register_policies

    news = create(:news_article, policy_content_ids: [policy_1["content_id"]])
    pr = DocumentListExportPresenter.new(news)
    assert_equal [policy_1["title"]], pr.policies
  end
end
