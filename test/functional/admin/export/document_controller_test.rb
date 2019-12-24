require "test_helper"

class Admin::Export::DocumentControllerTest < ActionController::TestCase
  test "show responds with JSON representation of a document" do
    document = stub_record(:document, id: 1, slug: "some-document")
    Document.stubs(:find).with(document.id.to_s).returns(document)

    login_as :export_data_user
    get :show, params: { id: document.id }, format: "json"
    assert_equal "some-document", json_response["slug"]
  end

  test "shows forbidden if user does not have export data permission" do
    login_as :world_editor
    get :show, params: { id: "1" }, format: "json"
    assert_response :forbidden
  end

  test "index responds with document information for a lead org and type" do
    org = create(:organisation)
    news_story = create(
      :news_article,
      organisations: [org],
      news_article_type: NewsArticleType::NewsStory,
    )

    login_as :export_data_user

    get :index, params: { lead_organisation: org.content_id,
                          type: "NewsArticle" }, format: "json"

    expected_response =
      {
        "documents" => [{
          "document_id" => news_story.document_id,
          "document_information" => {
            "locales" => %w[en],
            "subtypes" => %w[news_story],
            "lead_organisations" => [org.content_id],
          },
        }],
        "page_number" => 1,
        "page_count" => 1,
        "_response_info" => { "status" => "ok" },
    }

    assert_equal expected_response, json_response
  end

  test "doesnt return the document where the latest edition is not associated with lead org" do
    published_edition_org = create(:organisation)
    draft_edition_org = create(:organisation)
    document = create(:document)
    create(
      :news_article,
      :published,
      document: document,
      organisations: [published_edition_org],
      news_article_type: NewsArticleType::NewsStory,
    )

    create(
      :news_article,
      :draft,
      document: document,
      organisations: [draft_edition_org],
      news_article_type: NewsArticleType::NewsStory,
    )

    login_as :export_data_user

    get :index, params: { lead_organisation: published_edition_org.content_id,
                          type: "NewsArticle" }, format: "json"

    expected_response =
      {
        "documents" => [],
        "page_number" => 1,
        "page_count" => 0,
        "_response_info" => { "status" => "ok" },
    }

    assert_equal expected_response, json_response
  end

  test "returns the document for the first lead organisation" do
    first_lead_org = create(:organisation)
    edition = create(
      :news_article,
      :published,
      :with_document,
      news_article_type: NewsArticleType::NewsStory,
    )

    create(:edition_organisation, edition: edition, organisation: first_lead_org, lead: true, lead_ordering: 1)

    login_as :export_data_user

    get :index, params: { lead_organisation: first_lead_org.content_id,
                          type: "NewsArticle" }, format: "json"

    expected_response =
      {
        "documents" => [{
          "document_id" => edition.document_id,
          "document_information" => {
            "locales" => %w[en],
            "subtypes" => %w[news_story],
            "lead_organisations" => [first_lead_org.content_id, edition.organisations.last.content_id],
          },
        }],
        "page_number" => 1,
        "page_count" => 1,
        "_response_info" => { "status" => "ok" },
    }
    assert_equal expected_response, json_response
  end

  test "doesn't return the document if the lead organisation is not the first lead organisation" do
    second_lead_org = create(:organisation)
    edition = create(
      :news_article,
      :published,
      :with_document,
      news_article_type: NewsArticleType::NewsStory,
    )

    create(:edition_organisation, edition: edition, organisation: build(:organisation), lead: true, lead_ordering: 1)
    create(:edition_organisation, edition: edition, organisation: second_lead_org, lead: true, lead_ordering: 2)

    login_as :export_data_user

    get :index, params: { lead_organisation: second_lead_org.content_id,
                          type: "NewsArticle" }, format: "json"

    expected_response =
      {
        "documents" => [],
        "page_number" => 1,
        "page_count" => 0,
        "_response_info" => { "status" => "ok" },
    }

    assert_equal expected_response, json_response
  end

  test "lock returns forbidden if user does not have export data permission" do
    login_as :world_editor
    post :lock, params: { id: "1" }, format: "json"
    assert_response :forbidden
  end

  test "locks document" do
    document = create(:document)
    login_as :export_data_user

    post :lock, params: { id: document.id }, format: "json"

    assert document.reload.locked
    assert_response :no_content
  end

  test "unlock returns forbidden if user does not have export data permission" do
    login_as :world_editor
    post :unlock, params: { id: "1" }, format: "json"
    assert_response :forbidden
  end

  test "unlocks document" do
    document = create(:document, locked: true)
    login_as :export_data_user

    post :unlock, params: { id: document.id }, format: "json"

    assert_not document.reload.locked
    assert_response :no_content
  end

  test "marks locked document as migrated" do
    edition = create(:edition_with_document)
    edition.document.update(locked: true)
    login_as :export_data_user

    post :migrated, params: { id: edition.document.id }, format: "json"

    assert_response :no_content
  end

  test "removes migrated document from search index" do
    edition = create(:edition_with_document, body: "Some document being migrated to Content Publisher")
    edition.document.update(slug: "some-document", locked: true)
    create(:edition_with_document)
    login_as :export_data_user

    post :migrated, params: { id: edition.document.id }, format: "json"

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Whitehall::SearchIndex.delete(edition)]
  end

  test "does not mark unlocked document as migrated" do
    edition = create(:edition_with_document)
    login_as :export_data_user

    post :migrated, params: { id: edition.document.id }, format: "json"

    assert_response :bad_request
  end

  test "calls InternalLinkUpdater when document is marked as migrated" do
    edition_linked_to = create(:edition_with_document, body: "Some document being migrated to Content Publisher")
    edition_linked_to.document.update(slug: "some-document", locked: true)
    create(:edition_with_document)
    login_as :export_data_user

    post :migrated, params: { id: edition_linked_to.document.id }, format: "json"

    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Whitehall::InternalLinkUpdater]
  end

  test "calls FeaturedDocumentMigrator when document is marked as migrated" do
    edition = create(:published_news_article)
    create(:feature, document: edition.document, feature_list: create(:feature_list, locale: "en"))
    edition.document.update(slug: "some-document", locked: true)

    login_as :export_data_user

    assert_difference -> { OffsiteLink.count } do
      post :migrated, params: { id: edition.document.id }, format: "json"
    end

    assert_response :success
    assert_equal "content_publisher_press_release", OffsiteLink.last.link_type
  end

  test "calls DocumentCollectionGroupMembershipMigrator when document is marked as migrated" do
    edition = create(:published_news_article)
    create(:document_collection_group_membership, document: edition.document)
    edition.document.update(slug: "some-document", locked: true)

    login_as :export_data_user

    assert_difference -> { DocumentCollectionNonWhitehallLink.count } do
      post :migrated, params: { id: edition.document.id }, format: "json"
    end

    assert_response :success
    assert_equal "content-publisher", DocumentCollectionNonWhitehallLink.last.publishing_app
  end
end
