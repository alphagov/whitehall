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

  test "should be valid when a mainstream guide sub-page url is used" do
    content_id = SecureRandom.uuid
    stub_publishing_api_has_lookups("/foo" => content_id)
    stub_publishing_api_has_item(content_id:,
                                 title: "Foo Bar",
                                 base_path: "/foo",
                                 document_type: "guide",
                                 publishing_app: "content-publisher")

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/foo/subpage",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be valid when a Welsh-only url is used" do
    stub_welsh_only_page("/taluch-bil-treth-hunanasesiad")

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/taluch-bil-treth-hunanasesiad",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be valid when a Welsh-only mainstream guide sub-page url is used" do
    stub_welsh_only_page("/taluch-bil-treth-hunanasesiad", document_type: "guide")

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/taluch-bil-treth-hunanasesiad/taluch-bil-treth",
      document_collection_group: build(:document_collection_group),
    )

    assert url.valid?
  end

  test "should be invalid when the document exists in neither English nor Welsh" do
    content_id = SecureRandom.uuid
    stub_publishing_api_has_lookups("/no-such-locale" => content_id)
    stub_publishing_api_does_not_have_item(content_id)

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/no-such-locale",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
    assert url.errors.full_messages.include?("Url must reference a GOV.UK page")
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

  test "should be invalid when a non-mainstream guide sub-page url is used" do
    content_id = SecureRandom.uuid
    stub_publishing_api_has_lookups("/foo" => content_id)
    stub_publishing_api_has_item(content_id:,
                                 title: "Foo Bar",
                                 base_path: "/foo",
                                 document_type: "other",
                                 publishing_app: "content-publisher")

    url = DocumentCollectionNonWhitehallLink::GovukUrl.new(
      url: "https://www.gov.uk/foo/subpage",
      document_collection_group: build(:document_collection_group),
    )

    assert_not url.valid?
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

private

  def stub_welsh_only_page(base_path, document_type: "answer")
    content_id = SecureRandom.uuid

    stub_publishing_api_has_lookups(base_path => content_id)
    stub_publishing_api_does_not_have_item(content_id, locale: "en")
    stub_publishing_api_has_item(
      {
        content_id:,
        title: "Talu'ch bil treth Hunanasesiad",
        base_path:,
        document_type:,
        locale: "cy",
        publishing_app: "publisher",
      },
      locale: "cy",
    )

    content_id
  end
end
