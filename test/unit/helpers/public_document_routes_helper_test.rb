require 'test_helper'

class PublicDocumentRoutesHelperTest < ActionView::TestCase
  test 'uses the document identity to generate the route' do
    policy = create(:policy)
    assert_equal policy_path(policy.document_identity), public_document_path(policy)
  end

  test 'respects additional path options' do
    policy = create(:policy)
    assert_equal policy_path(policy.document_identity, anchor: 'additional'), public_document_path(policy, anchor: 'additional')
  end

  test 'returns the policy_path for Policy instances' do
    policy = create(:policy)
    assert_equal policy_path(policy.document_identity), public_document_path(policy)
  end

  test 'returns the publication_path for Publication instances' do
    publication = create(:publication)
    assert_equal publication_path(publication.document_identity), public_document_path(publication)
  end

  test 'returns the news_article_path for NewsArticle instances' do
    news_article = create(:news_article)
    assert_equal news_article_path(news_article.document_identity), public_document_path(news_article)
  end

  test 'returns the consultation_path for Consultation instances' do
    consultation = create(:consultation)
    assert_equal consultation_path(consultation.document_identity), public_document_path(consultation)
  end

  test 'returns the singleton consultation_response_path for ConsultationResponse instances' do
    consultation_response = create(:consultation_response)
    assert_equal consultation_response_path(consultation_response.consultation.document_identity), public_document_path(consultation_response)
  end
end
