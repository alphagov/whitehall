require "test_helper"

class DocumentCollectionNonWhitehallLink::GovukUrlTest < ActiveSupport::TestCase
  setup do
    @content_id = SecureRandom.uuid
    Services.content_store.stubs(:content_item).with("/test").returns(
      "content_id" => @content_id,
      "title" => "Test",
      "base_path" => "/test",
      "publishing_app" => "content-publisher",
    )
  end

  test "should be valid when content store has the path" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/test",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be valid when an integration GOV.UK url is used" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://integration.publishing.service.gov.uk/test",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be valid when a mainstream guide sub-page url is used" do
    content_id = SecureRandom.uuid
    Services.content_store.stubs(:content_item).with("/foo/subpage").returns(
      "content_id" => content_id,
      "title" => "Foo Bar",
      "base_path" => "/foo",
      "publishing_app" => "content-publisher",
      "document_type" => "guide",
    )

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/foo/subpage",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be invalid without a url" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: nil,
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
  end

  test "should be invalid without a document collection group" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/test",
      document_collection_group: nil,
    )

    assert_not url.valid?
  end

  test "should be invalid when an invalid URL is used" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "invalid URL",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
    assert url.errors.full_messages.include?("Url must be a valid GOV.UK URL")
  end

  test "should be invalid when a non-GOV.UK URL is used" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.google.com/test",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
    assert url.errors.full_messages.include?("Url must be a valid GOV.UK URL")
  end

  test "should be valid for a Welsh-only GOV.UK page (locale: cy)" do
    welsh_content_id = SecureRandom.uuid
    content_store_response = { "content_id" => welsh_content_id, "title" => "Talu TWE y cyflogwr", "base_path" => "/talu-treth-twe", "publishing_app" => "publisher", "locale" => "cy" }
    Services.content_store.stubs(:content_item).with("/talu-treth-twe").returns(content_store_response)

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/talu-treth-twe",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be valid for an unpublished URL found only in the draft content store" do
    draft_content_id = SecureRandom.uuid
    Services.content_store.stubs(:content_item).with("/unpublished").raises(GdsApi::ContentStore::ItemNotFound.new(404))
    Services.draft_content_store.stubs(:content_item).with("/unpublished").returns(
      "content_id" => draft_content_id,
      "title" => "Unpublished",
      "base_path" => "/unpublished",
      "publishing_app" => "whitehall",
    )

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/unpublished",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be invalid when neither content store has the path" do
    Services.content_store.stubs(:content_item).raises(GdsApi::ContentStore::ItemNotFound.new(404))
    Services.draft_content_store.stubs(:content_item).raises(GdsApi::ContentStore::ItemNotFound.new(404))

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/test",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
    assert url.errors.full_messages.include?("Url must reference a GOV.UK page")
  end

  test "should be invalid when a non-mainstream guide sub-page url is used" do
    content_id = SecureRandom.uuid
    Services.content_store.stubs(:content_item).with("/foo/subpage").returns(
      "content_id" => content_id,
      "title" => "Foo Bar",
      "base_path" => "/foo",
      "publishing_app" => "content-publisher",
      "document_type" => "other",
    )

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/foo/subpage",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
  end

  test "should be invalid when Content Store is unavailable" do
    Services.content_store.stubs(:content_item).raises(GdsApi::HTTPIntermittentServerError.new(503))

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/test",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
    assert url.errors.full_messages.include?("Link lookup failed, please try again later")
  end

  test "#save should create a document collection group membership" do
    group = create(:document_collection_group)
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/test",
      document_collection_group: group,
    )

    assert_difference -> { group.memberships.size }, 1 do
      url.save
    end

    non_whitehall_link = group.memberships.last.non_whitehall_link

    assert_equal non_whitehall_link.as_json(only: %w[base_path content_id publishing_app title]),
                 "base_path" => "/test",
                 "content_id" => @content_id,
                 "publishing_app" => "content-publisher",
                 "title" => "Test"
  end

  test "#save return nil when it is invalid" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: nil,
      document_collection_group: nil,
    )

    assert_nil url.save
  end
end
