require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  test "should render 404 if the document doesn't have a published edition" do
    document = create(:document)
    get :show, id: document.to_param

    assert_response :not_found
  end

  test 'should display the published edition' do
    document = create(:document)
    create(:archived_edition, document: document)
    published_edition = create(:published_edition, document: document)
    create(:draft_edition, document: document)
    get :show, id: document.to_param

    assert_response :success
    assert_equal published_edition, assigns[:published_edition]
  end

  test "should render the content using govspeak markup" do
    published_document = create(:document, editions: [build(:published_edition, body: "body-text")])

    govspeak_document = mock("govspeak-document")
    govspeak_document.stubs(:to_html).returns("body-text-as-govspeak")
    Govspeak::Document.stubs(:new).with("body-text").returns(govspeak_document)

    get :show, id: published_document.to_param

    assert_select ".body", text: "body-text-as-govspeak"
  end

  test 'should only display published documents' do
    draft_document = create(:document, editions: [build(:draft_edition)])
    published_document = create(:document, editions: [build(:published_edition)])
    archived_document = create(:document, editions: [build(:archived_edition)])
    get :index

    assert_response :success
    assert_equal [published_document], assigns[:documents]
  end

  test 'should distinguish between document types when viewing the list of documents' do
    policy, publication = create(:policy), create(:publication)
    create(:published_edition, document: policy)
    create(:published_edition, document: publication)
    get :index

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end
end
