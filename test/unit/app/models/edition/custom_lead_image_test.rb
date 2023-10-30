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
end
