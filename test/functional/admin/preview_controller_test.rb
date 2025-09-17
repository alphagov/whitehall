require "test_helper"

class Admin::PreviewControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  view_test "renders the body param using govspeak into a document body template" do
    post :preview, params: { body: "# gov speak" }
    assert_select ".document .body h1", "gov speak"
  end

  view_test "renders attached images if image_ids provided using !!number as a markdown" do
    edition = create(:publication, body: "!!1")
    image = create(:image, edition:)

    post :preview, params: { body: edition.body, image_ids: edition.images.map(&:id) }
    assert_select ".document .body figure.image.embedded img[src=?]", image.url
  end

  view_test "renders attached images if image_ids provided using filename as a markdown" do
    edition = create(:publication, body: "[Image: minister-of-funk.960x640.jpg]")
    image = create(:image, edition:)

    post :preview, params: { body: edition.body, image_ids: edition.images.map(&:id) }
    assert_select ".document .body figure.image.embedded img[src=?]", image.url
  end

  view_test "renders attached files if attachment_ids provided" do
    edition = create(:published_detailed_guide, :with_file_attachment, body: "#Heading\n\n!@1\n\n##Subheading")

    post :preview, params: { body: edition.body, attachment_ids: edition.attachments.map(&:id) }

    assert_select ".document .body .govspeak section div a[href=?]", edition.attachments.first.url
  end

  view_test "shows alternative_format_contact_email in attachment block if alternative_format_provider_id given" do
    email = "alternative@example.com"
    edition = create(:published_detailed_guide, :with_file_attachment, body: "!@1")
    alternative_format_provider = create(:organisation, alternative_format_contact_email: email)

    post :preview, params: { body: edition.body, attachment_ids: edition.attachments.map(&:id), alternative_format_provider_id: alternative_format_provider.id }

    assert_select "a[href=?]", "mailto:#{email}", text: email
  end

  test "preview succeeds if alternative_format_provider_id is blank" do
    edition = create(:published_detailed_guide, :with_file_attachment, body: "!@1")

    post :preview, params: { body: edition.body, attachment_ids: edition.attachments.map(&:id), alternative_format_provider_id: "" }
    assert_response :success
  end

  test "preview returns a 403 if the content contains potential XSS exploits" do
    post :preview, params: { body: "<script>alert('woah');</script>" }
    assert_response :forbidden
  end

  test "preview returns a 403 if any of the referenced attachments are inaccessible to the current user" do
    protected_edition = create(:draft_publication, :access_limited)
    attachment = create(:file_attachment, attachable: protected_edition)

    post :preview, params: { body: "blah", attachment_ids: [attachment.id] }
    assert_response :forbidden
  end

  view_test "shows rendered content block when an embed code is found" do
    govspeak = <<~MD
      some content...
      {{embed:content_block_pension:my-content-block/rates/rate-1/amount}}
    MD

    html = <<~HTML
      <span class="content-block">£123</span>
    HTML

    ContentBlock::FindAndReplaceEmbedCodesService.expects(:call).with(govspeak).returns(html)

    post :preview, params: { body: govspeak }

    assert_select "span.content-block", "£123"
  end
end
