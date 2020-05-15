require "test_helper"

class DocumentCollectionNonWhitehallLink::GovukUrlTest < ActiveSupport::TestCase
  setup do
    @content_id = SecureRandom.uuid
    stub_publishing_api_has_lookups("/test" => @content_id)
    stub_publishing_api_has_item(
      content_id: @content_id,
      title: "Test",
      base_path: "/test",
      publishing_app: "content-publisher",
    )
  end

  test "should be valid without a GOV.UK url that Publishing API knows" do
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

  test "should be invalid when a GOV.UK URL that isn't in the Publishing API" do
    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/different-path",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
    assert url.errors.full_messages.include?("Url must reference a GOV.UK page")
  end

  test "should be invalid when Publishing API returns a 404" do
    stub_any_publishing_api_call_to_return_not_found

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/test",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
    assert url.errors.full_messages.include?("Url must reference a GOV.UK page")
  end

  test "should be invalid when Publishing API is down" do
    stub_publishing_api_isnt_available

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
