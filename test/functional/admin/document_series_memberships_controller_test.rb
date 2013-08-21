require 'test_helper'

class Admin::DocumentSeriesMembershipsControllerTest < ActionController::TestCase
  setup do
    @document_series = create(:document_series)
    login_as create(:policy_writer)
  end

  should_be_an_admin_controller

  view_test 'GET #index lists the documents in the series' do
    doc1 = create(:published_publication)
    doc2 = create(:published_publication)
    @document_series.documents = [doc1.document, doc2.document]

    get :index, document_series_id: @document_series

    assert_select 'a', doc1.title
    assert_select 'a', doc2.title
  end

  test 'JS POST #create adds the document to the series' do
    document = create(:publication).document
    xhr :post, :create, document_series_id: @document_series, id: document.id

    assert_response :success
    assert_template :create
    assert @document_series.documents.include?(document), "Document #{document.id} should be in series"
  end

  test 'JS DELETE #destroy removes a document from the series' do
    document = create(:publication).document
    @document_series.documents << document
    xhr :delete, :destroy, document_series_id: @document_series, id: document.id

    assert_response :success
    assert_template :destroy
    refute @document_series.documents(true).include?(document), "Document #{document.id} should not be in series"
  end

  view_test 'JSON GET #search returns filter results as JSON' do
    publication = create(:publication, title: 'search term')

    get :search, document_series_id: @document_series, title: 'search term', format: :json

    assert_response :success

    response_as_hash = JSON.parse(response.body)
    assert_equal true, response_as_hash['results_any?']
    assert_equal 1, response_as_hash['results'].size

    publication_json = response_as_hash['results'][0]
    assert_equal publication.id, publication_json['id']
    assert_equal publication.document_id, publication_json['document_id']
    assert_equal publication.title, publication_json['title']
    assert_equal 'publication', publication_json['type']
    assert_equal publication.display_type, publication_json['display_type']
  end
end
