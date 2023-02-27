require "test_helper"

class DocumentCollectionControllerRedirectsTest < ActionDispatch::IntegrationTest
  test "old route (eg. /government/organisations/?/series/?) should redirect to this show action" do
    document_collection = build(:document_collection, document: build(:document, slug: "firing_notice"))

    get "/government/organisations/ministry-of-defence/series/firing-notice"

    assert response.redirect?
    assert response.location = document_collection.public_url(locale: :en)
  end
end
