require "test_helper"

class DocumentCollectionsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'index should display document collections for an organisation' do
    organisation = create(:organisation)
    alpha = create(:document_collection, organisation: organisation, name: "alpha")
    beta = create(:document_collection, organisation: organisation, name: "beta")

    get :index, organisation_id: organisation

    assert_select_object(alpha) { assert_select ".name", "alpha" }
    assert_select_object(beta) { assert_select ".name", "beta" }
  end

  test 'show should display published documents within a collection' do
    organisation = create(:organisation)
    collection = create(:document_collection, organisation: organisation)
    publication = create(:published_publication, document_collections: [collection])
    draft_publication = create(:draft_publication, document_collections: [collection])

    get :show, organisation_id: organisation, id: collection

    assert_select_object(publication)
    refute_select_object(draft_publication)
  end
end
