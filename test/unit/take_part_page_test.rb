require 'test_helper'

class TakePartPageTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :body

  test "invalid without a title" do
    refute build(:take_part_page, title: nil).valid?
  end

  test "limits title to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.title = ('a' * 254)
    assert page.valid?

    page.title = ('a' * 255)
    assert page.valid?

    page.title = ('a' * 256)
    refute page.valid?
  end

  test "sets a slug from the organisation name" do
    page = create(:take_part_page, title: 'Show me the money')
    assert_equal 'show-me-the-money', page.slug
  end

  test "won't change the slug when the name is changed" do
    page = create(:take_part_page, title: 'Show me the money')
    page.update_attributes(title: 'You had me at hello')
    assert_equal 'show-me-the-money', page.slug
  end

  test "invalid without a body" do
    refute build(:take_part_page, body: nil).valid?
  end

  test "limits body to a maximum of (16.megabytes - 1) characters" do
    page = build(:take_part_page)

    page.body = ('a' * (16.megabytes - 2)) # 1 less
    assert page.valid?

    page.body += 'a' # exact
    assert page.valid?

    page.body += 'a' # 1 bigger
    refute page.valid?
  end

  test "invalid without a summary" do
    refute build(:take_part_page, summary: nil).valid?
  end

  test "limits summary to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.summary = ('a' * 254)
    assert page.valid?

    page.summary = ('a' * 255)
    assert page.valid?

    page.summary = ('a' * 256)
    refute page.valid?
  end

  test "invalid without image on create" do
    refute build(:take_part_page, image: nil).valid?
  end

  test "invalid without image alt text on create" do
    refute build(:take_part_page, image_alt_text: nil).valid?
  end

  test "limits image alt text to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.image_alt_text = ('a' * 254)
    assert page.valid?

    page.image_alt_text = ('a' * 255)
    assert page.valid?

    page.image_alt_text = ('a' * 256)
    refute page.valid?
  end

end
