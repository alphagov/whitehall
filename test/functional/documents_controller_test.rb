require "test_helper"

class DocumentsControllerTest < ActionController::TestCase
  test "should render 404 if the document doesn't have a published document" do
    document_identity = create(:document_identity)
    get :show, id: document_identity.to_param

    assert_response :not_found
  end

  test "should display the published document" do
    document_identity = create(:document_identity)
    create(:archived_policy)
    published_document = create(:published_policy, document_identity: document_identity)
    create(:draft_policy, document_identity: document_identity)
    get :show, id: document_identity.to_param

    assert_response :success
    assert_equal published_document, assigns[:document]
  end

  test "should render the content using govspeak markup" do
    published_policy = create(:published_policy, body: "body-text")
    govspeak_document = mock("govspeak-document")
    govspeak_document.stubs(:to_html).returns("body-text-as-govspeak")
    Govspeak::Document.stubs(:new).with("body-text").returns(govspeak_document)

    get :show, id: published_policy.document_identity.to_param

    assert_select ".body", text: "body-text-as-govspeak"
  end

  test "should display topics" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    document = create(:published_policy, topics: [first_topic, second_topic])

    get :show, id: document.document_identity.to_param

    assert_select topics_selector, count: 1
    assert_select ".topic", text: first_topic.name
    assert_select ".topic", text: second_topic.name
  end

  test "should not display the topics section if there aren't any" do
    document = create(:published_policy)

    get :show, id: document.document_identity.to_param

    assert_select topics_selector, count: 0
  end

  test "should display organisations" do
    first_org = create(:organisation)
    second_org = create(:organisation)
    document = create(:published_policy, organisations: [first_org, second_org])

    get :show, id: document.document_identity.to_param

    assert_select organisations_selector, count: 1
    assert_select ".organisation", text: first_org.name
    assert_select ".organisation", text: second_org.name
  end

  test "should not display the organisations section if there aren't any" do
    document = create(:published_policy)

    get :show, id: document.document_identity.to_param

    assert_select organisations_selector, count: 0
  end

  test "should display the minister section" do
    document = create(:published_policy, roles: [build(:role)])

    get :show, id: document.document_identity.to_param

    assert_select ministers_responsible_selector, count: 1
  end

  test "should not display an empty ministers section" do
    document = create(:published_policy)

    get :show, id: document.document_identity.to_param

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

  def organisations_selector
    "#organisations"
  end

  def topics_selector
    "#topics"
  end

  def ministers_responsible_selector
    "#ministers_responsible"
  end
end
