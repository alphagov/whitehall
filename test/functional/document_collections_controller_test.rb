require "test_helper"

class DocumentCollectionControllerRedirectsTest < ActionDispatch::IntegrationTest
  test "old route (eg. /government/organisations/?/series/?) should redirect to this show action" do
    get '/government/organisations/ministry-of-defence/series/firing-notice'

    assert response.redirect?
    assert response.location = document_collection_url(id: 'firing-notice')
  end
end
