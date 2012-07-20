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
    attachment = create(:attachment)
    edition = create(:published_specialist_guide, body: '!@1', attachments: [attachment])

    post :preview, body: edition.body, attachment_ids: edition.attachments.map(&:id)
    assert_select ".document .body" do
      assert_select_object attachment
    end
  end

  test "renders lead image if provided" do
    edition = create(:news_article, images: [build(:image)])

    post :preview, body: edition.body, lead_image_id: edition.lead_image
    assert_select ".document .body figure.image.lead img[src=?]", edition.lead_image.url
  end

end