require "test_helper"

class Edition::CustomLeadImageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def edition_with_custom_lead_image(options = {})
    image1 = build(:image)
    image2 = build(:image)

    build(:draft_news_article, options.merge(images: [image1, image2], lead_image: image2))
  end

  def body_text_valid(body)
    edition_with_custom_lead_image(body:).valid?
  end

  test "validates that the lead image is not included in the body text" do
    assert_not body_text_valid("foo\n!!2\nbar")
    assert_not body_text_valid("foo\n!!2 \nbar")
    assert_not body_text_valid("foo\n!!2")
    assert_not body_text_valid("foo\n!!2s\nbar")
    assert_not body_text_valid("foo\[Image: minister-of-funk.960x640.jpg]\nbar")
    assert_not body_text_valid("foo\[Image:minister-of-funk.960x640.jpg]\nbar")
    assert_not body_text_valid("foo\[Image:     minister-of-funk.960x640.jpg]\nbar")
    assert_not body_text_valid("foo\[Image:  \n  minister-of-funk.960x640.jpg]\nbar")
    assert body_text_valid("foo\n!!20\nbar")
    assert body_text_valid("foo\nfoo bar !!2\nbar")
    assert body_text_valid("foo\[Image: anotherfilename.jpg]\nbar")
  end

  test "#update_lead_image updates the lead_image association to the oldest image" do
    image1 = build(:image)
    image2 = build(:image)
    edition = create(:news_article, images: [image1, image2])

    edition.update_lead_image

    assert_equal image1, edition.reload.lead_image
  end

  test "#update_lead_image deletes the associated edition_lead_image if image_display_option is 'no_image'" do
    edition_lead_image = build(:edition_lead_image)
    edition = build(:news_article, image_display_option: "no_image", edition_lead_image:)

    edition_lead_image
    .expects(:destroy!)
    .once

    edition
    .expects(:build_edition_lead_image)
    .never

    edition.update_lead_image
  end

  test "#update_lead_image deletes the associated edition_lead_image if image_display_option is 'organisation_image'" do
    edition_lead_image = build(:edition_lead_image)
    edition = build(:news_article, image_display_option: "organisation_image", edition_lead_image:)

    edition_lead_image
    .expects(:destroy!)
    .once

    edition
    .expects(:build_edition_lead_image)
    .never

    edition.update_lead_image
  end

  test "#update_lead_image returns nil if lead_image is present" do
    image = build(:image)
    edition = build(:news_article, images: [image], lead_image: image)

    edition
    .expects(:build_edition_lead_image)
    .never

    assert_nil edition.update_lead_image
  end

  test "#update_lead_image returns nil if no images are present" do
    edition = build(:news_article)

    edition
    .expects(:build_edition_lead_image)
    .never

    assert_nil edition.update_lead_image
  end

  test "#non_lead_images returns images which are not lead images" do
    image1 = build(:image)
    image2 = build(:image)
    edition = build(:news_article, images: [image1, image2], lead_image: image1)

    assert_equal [image2], edition.non_lead_images
  end
end
