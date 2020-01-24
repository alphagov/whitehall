require "test_helper"

class BrexitNoDealContentNoticeLinkTest < ActiveSupport::TestCase
  setup do
    @content_id = SecureRandom.uuid
    stub_publishing_api_has_lookups("/test" => @content_id)
    stub_publishing_api_has_item(content_id: @content_id,
                                 title: "Test",
                                 base_path: "/test",
                                 publishing_app: "content-publisher")
  end

  test "should be invalid with a malformed url" do
    link = BrexitNoDealContentNoticeLink.new(title: "External Link", url: "htps://example.com/foo")

    link.valid?

    assert_includes link.errors.full_messages, "Url is not valid. Make sure it starts with http(s)"
  end

  test "is invalid if the title is longer than 255 characters" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "a" * 256,
      url: "https://www.gov.uk/test",
    )

    assert_not link.valid?
  end

  test "an external link should be a valid URL" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "External Link",
      url: "https://www.google.com",
    )

    assert link.valid?
  end

  test "should be invalid when a GOV.UK URL points to content that is absent from Publishing API" do
    stub_any_publishing_api_call_to_return_not_found

    link = BrexitNoDealContentNoticeLink.new(
      title: "Not an existing GOV.UK page",
      url: "https://www.gov.uk/path-to-no-document",
    )

    link.valid?

    assert_includes link.errors.full_messages, "Url must reference a GOV.UK page"
  end

  test "should be valid when a GOV.UK URL points to content that exists in Publishing API" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "GOV.UK Test",
      url: "https://www.gov.uk/test",
    )

    assert link.valid?
  end

  test "should be invalid when Publishing API is down" do
    stub_publishing_api_isnt_available

    link = BrexitNoDealContentNoticeLink.new(
      title: "GOV.UK Test",
      url: "https://www.gov.uk/test",
    )

    link.valid?

    assert_includes link.errors.full_messages, "Link lookup failed, please try again later"
  end

  test "link is considered internal if the host is GOV.UK" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "GOV.UK Test",
      url: "https://www.gov.uk/test",
    )

    assert link.is_internal?
  end

  test "link is considered internal if it consists only of a path" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "GOV.UK Test",
      url: "/test",
    )

    assert link.is_internal?
  end

  test "external link is not an internal one" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "External",
      url: "https://www.example.com/2",
    )

    assert_not link.is_internal?
  end

  test "link title is not a URL" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "https://www.example.com/2",
      url: "https://www.example.com/2",
    )

    link.valid?

    assert_includes link.errors.full_messages, "Title can't be a URL"
  end

  test "title must be present if URL is specified" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "",
      url: "https://www.example.com/2",
    )

    link.valid?

    assert_includes link.errors.full_messages, "Title can't be blank"
  end

  test "URL must be present if title is specified" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "Link title",
      url: "",
    )

    link.valid?

    assert_includes link.errors.full_messages, "Url can't be blank"
  end

  test "path is a valid internal URL" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "Internal Link",
      url: "/test",
    )

    assert link.valid?
  end

  test "non-existent path is invalid internal URL" do
    link = BrexitNoDealContentNoticeLink.new(
      title: "Internal Link",
      url: "/foobar",
    )

    assert_not link.valid?
  end
end
