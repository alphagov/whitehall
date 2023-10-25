require "test_helper"

class Edition::CustomLeadImageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def edition_with_custom_lead_image(options = {})
    build(:draft_news_article, options)
  end

  test "reports that the first image is not available for adding inline" do
    assert edition_with_custom_lead_image.image_disallowed_in_body_text?(1)
  end

  test "reports other images are not disallowed" do
    assert_not edition_with_custom_lead_image.image_disallowed_in_body_text?(2)
  end

  def body_text_valid(body)
    edition_with_custom_lead_image(body:).valid?
  end

  test "validates that the first image is not included in the body text" do
    assert_not body_text_valid("foo\n!!1\nbar")
    assert_not body_text_valid("foo\n!!1 \nbar")
    assert_not body_text_valid("foo\n!!1")
    assert_not body_text_valid("foo\n!!1s\nbar")
    assert body_text_valid("foo\n!!10\nbar")
    assert body_text_valid("foo\nfoo bar !!1\nbar")
  end

  test "#update_lead_image updates the lead_image association to the oldest image" do
    image1 = build_stubbed(:image)
    image2 = build_stubbed(:image)
    edition = build_stubbed(:news_article, images: [image1, image2])

    edition.stubs(:lead_image).returns(nil)
    edition.images.stubs(:order).with(:created_at, :id).returns([image1, image2])
    edition_lead_image = mock

    edition
    .expects(:build_edition_lead_image)
    .with(image: image1)
    .once
    .returns(edition_lead_image)

    edition_lead_image
    .expects(:save!)
    .once
    .returns(true)

    edition.update_lead_image
  end

  test "#update_lead_image deletes the associated edition_lead_image if image_display_option is 'no_image'" do
    edition_lead_image = build(:edition_lead_image)
    edition = build(:news_article, image_display_option: "no_image", edition_lead_image:)

    edition_lead_image
    .expects(:destroy!)
    .once

    edition.update_lead_image
  end

  test "#update_lead_image deletes the associated edition_lead_image if image_display_option is 'organisation_image'" do
    edition_lead_image = build(:edition_lead_image)
    edition = build(:news_article, image_display_option: "organisation_image", edition_lead_image:)

    edition_lead_image
    .expects(:destroy!)
    .once

    edition.update_lead_image
  end

  test "#update_lead_image returns nil if lead_image is present" do
    edition = build(:news_article)
    build(:image)
    edition.stubs(:lead_image).returns(edition)

    assert_nil edition.update_lead_image
  end

  test "#update_lead_image returns nil if no images are present" do
    edition = build(:news_article)
    assert_nil edition.update_lead_image
  end
end
