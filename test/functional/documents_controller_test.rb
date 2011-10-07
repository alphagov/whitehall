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

  test "should display topics" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    edition = create(:published_edition, topics: [first_topic, second_topic])

    get :show, id: edition.document.to_param

    assert_select ".topic", text: first_topic.name
    assert_select ".topic", text: second_topic.name
  end

  test "should not display the topics section if there aren't any" do
    edition = create(:published_edition)

    get :show, id: edition.document.to_param

    assert_select "#topics", count: 0
  end

  test "should display organisations" do
    first_org = create(:organisation)
    second_org = create(:organisation)
    edition = create(:published_edition, organisations: [first_org, second_org])

    get :show, id: edition.document.to_param

    assert_select ".organisation", text: first_org.name
    assert_select ".organisation", text: second_org.name
  end

  test "should not display the organisations section if there aren't any" do
    edition = create(:published_edition)

    get :show, id: edition.document.to_param

    assert_select "#organisations", count: 0
  end
  
  test "should display the minister section" do
    edition = create(:published_edition, ministers: [build(:minister)])

    get :show, id: edition.document.to_param

    assert_select ministers_responsible_selector, count: 1
  end
  
  test "should not display an empty ministers section" do
    edition = create(:published_edition)

    get :show, id: edition.document.to_param

    assert_select ministers_responsible_selector, count: 0
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
  
  private
  
  def ministers_responsible_selector
    "#ministers_responsible"
  end
end
