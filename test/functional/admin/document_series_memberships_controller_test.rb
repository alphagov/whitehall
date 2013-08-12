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
end
