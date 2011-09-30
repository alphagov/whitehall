require 'test_helper'

class PoliciesControllerTest < ActionController::TestCase
  test 'show policy with one draft edition' do
    draft_edition = create(:draft_edition)
    get :show, id: draft_edition.document.to_param

    assert_response :not_found
  end

  test 'show policy with one published edition' do
    published_edition = create(:published_edition)
    get :show, id: published_edition.document.to_param

    assert_response :success
    assert_equal published_edition, assigns[:edition]
  end

  test 'show policy with one published edition and one draft edition' do
    published_edition = create(:published_edition)
    edition = create(:draft_edition, document: published_edition.document)
    get :show, id: published_edition.document.to_param

    assert_response :success
    assert_equal published_edition, assigns[:edition]
  end

  test 'show policy with one published edition and one archived edition' do
    archived_edition = create(:archived_edition)
    published_edition = create(:published_edition, document: archived_edition.document)

    get :show, id: archived_edition.document.to_param

    assert_response :success
    assert_equal published_edition, assigns[:edition]
  end

  test 'index policy with one draft edition' do
    draft_edition = create(:draft_edition)
    get :index

    assert_equal [], assigns[:documents]
  end

  test 'index policy with one published edition' do
    document = create(:document)
    published_edition = create(:published_edition, document: document)
    get :index

    assert_response :success
    assert_equal [document], assigns[:documents]
  end

  test 'index policy with one published edition and one draft edition' do
    document = create(:document)
    published_edition = create(:published_edition, document: document)
    edition = create(:draft_edition, document: document)
    get :index

    assert_response :success
    assert_equal [document], assigns[:documents]
  end

  test 'index policy with one published edition and one archived edition' do
    document = create(:document)
    archived_edition = create(:archived_edition, document: document)
    published_edition = create(:published_edition, document: document)

    get :index

    assert_response :success
    assert_equal [document], assigns[:documents]
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
