require "test_helper"

class DocumentsControllerTest < ActionController::TestCase
  test "should render 404 if the document doesn't have a published edition" do
    document = create(:document)
    get :show, id: document.to_param

    assert_response :not_found
  end

  test "should display the published edition" do
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

  test "should not display the topics section if there aren't any" do
    edition = create(:published_edition)

    get :show, id: edition.document.to_param

    assert_select "#topics", count: 0
  end

  test "should not display the organisations section if there aren't any" do
    edition = create(:published_edition)

    get :show, id: edition.document.to_param

    assert_select "#topics", count: 0
  end

  test "should only display published policies" do
    archived_policy = create(:archived_policy)
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)
    get :index

    assert_select_object(published_policy)
    assert_select_object(archived_policy, count: 0)
    assert_select_object(draft_policy, count: 0)
  end

  test "should only display published publications" do
    archived_publication = create(:archived_publication)
    published_publication = create(:published_publication)
    draft_publication = create(:draft_publication)
    get :index

    assert_select_object(published_publication)
    assert_select_object(archived_publication, count: 0)
    assert_select_object(draft_publication, count: 0)
  end
end
