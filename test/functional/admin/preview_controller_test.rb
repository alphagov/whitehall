require 'test_helper'

class Admin::PreviewControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "renders the body param using govspeak into a document body template" do
    post :preview, body: "# gov speak"
    assert_select ".document .body h1", "gov speak"
  end

  test "renders attached images if image_ids provided" do
    edition = create(:policy, body: '!!1')
    image = create(:image, edition: edition)

    post :preview, body: edition.body, image_ids: edition.images.map(&:id)
    assert_select ".document .body figure.image.embedded img[src=?]", %r{#{image.url}}
  end

  test "renders attached files if attachment_ids provided" do
    edition = create(:published_detailed_guide, :with_attachment, body: '!@1')

    post :preview, body: edition.body, attachment_ids: edition.attachments.map(&:id)
    assert_select ".document .body" do
      assert_select_object edition.attachments.first
    end
  end

  test "shows alternative_format_contact_email in attachment block if alternative_format_provider_id given" do
    edition = create(:published_detailed_guide, :with_attachment, body: '!@1')
    alternative_format_provider = create(:organisation, alternative_format_contact_email: "alternative@example.com")

    post :preview, body: edition.body, attachment_ids: edition.attachments.map(&:id), alternative_format_provider_id: alternative_format_provider.id
    assert_select ".document .body" do
      assert_select_object edition.attachments.first do
        assert_select "a[href^=\"mailto:alternative@example.com\"]"
      end
    end
  end

  test "preview succeeds if alternative_format_provider_id is blank" do
    edition = create(:published_detailed_guide, :with_attachment, body: '!@1')

    post :preview, body: edition.body, attachment_ids: edition.attachments.map(&:id), alternative_format_provider_id: ""
    assert_response :success
  end

  test "preview returns a 403 if the content contains potential XSS exploits" do
    post :preview, body: "<script>alert('woah');</script>"
    assert_response :forbidden
  end
end
