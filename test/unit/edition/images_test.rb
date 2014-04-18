require 'test_helper'

class Edition::ImagesTest < ActiveSupport::TestCase
  class EditionWithImages < Edition
    include ::Edition::Images
  end

  include ActionDispatch::TestProcess

  test "editions can be created with multiple images" do
    edition = EditionWithImages.create!(valid_edition_attributes.merge(
      images_attributes: [
      {alt_text: "Something about this image",
       caption: "Text to be visible along with the image",
       image_data_attributes: {file: fixture_file_upload('minister-of-funk.960x640.jpg')}},
      {alt_text: "alt-text-2",
       caption: "caption-2",
       image_data_attributes: {file: fixture_file_upload('minister-of-funk.960x640.jpg')}}
    ]))

    assert_equal 2, edition.images.count
    assert_equal "Something about this image", edition.images[0].alt_text
    assert_equal "Text to be visible along with the image", edition.images[0].caption
    assert_equal "alt-text-2", edition.images[1].alt_text
    assert_equal "caption-2", edition.images[1].caption
  end

  test "#create_draft should not silently fail to copy images over to the new edition" do
    image = create(:image)
    published_edition = EditionWithImages.create!(valid_edition_attributes.merge(
      state: 'published',
      major_change_published_at: Time.zone.now,
      first_published_at: Time.zone.now,
      images: [image]
    ))
    VirusScanHelpers.simulate_virus_scan

    # to cause validation error on create_draft
    image.update_attribute(:image_data_id, nil)

    assert_raise ActiveRecord::RecordInvalid, "Validation failed: Image data file can't be blank" do
      published_edition.create_draft(build(:user))
    end
  end

  test "#create_draft should include copies of image attributes" do
    image = create(:image)
    published_edition = EditionWithImages.create!(valid_edition_attributes.merge(
      state: 'published',
      major_change_published_at: Time.zone.now,
      first_published_at: Time.zone.now,
      images: [image]
    ))
    VirusScanHelpers.simulate_virus_scan

    draft_edition = published_edition.create_draft(build(:user))
    draft_edition.change_note = 'change-note'

    assert draft_edition.valid?

    new_image = draft_edition.images.last
    refute_equal image, new_image
    assert_equal image.alt_text, new_image.alt_text
    assert_equal image.caption, new_image.caption
  end

  test "#create_draft should not duplicate the actual image data" do
    image = create(:image)
    published_edition = EditionWithImages.create!(valid_edition_attributes.merge(
      state: 'published',
      major_change_published_at: Time.zone.now,
      first_published_at: Time.zone.now,
      images: [image]
    ))
    VirusScanHelpers.simulate_virus_scan

    draft_edition = published_edition.create_draft(build(:user))
    new_image = draft_edition.images.last

    assert_equal image.image_data_id, new_image.image_data_id
  end

  test "captions for images can be changed between versions" do
    published_edition = EditionWithImages.create!(valid_edition_attributes.merge(
      state: 'published',
      major_change_published_at: Time.zone.now,
      first_published_at: Time.zone.now,
      images_attributes:  [{
        alt_text: "alt-text",
        caption: "original-caption",
        image_data_attributes: {
          file: fixture_file_upload('minister-of-funk.960x640.jpg')
        }
      }]
    ))
    VirusScanHelpers.simulate_virus_scan

    draft_edition = published_edition.create_draft(build(:user))
    draft_edition.images.first.update_attributes(caption: "new-caption")

    assert_equal "original-caption", published_edition.images.first.caption
  end

  test "#destroy should also remove the image" do
    image = create(:image)
    edition = EditionWithImages.create!(valid_edition_attributes.merge(images: [image]))
    edition.destroy
    refute Image.find_by_id(image.id)
  end

  test "should indicate that it allows image attachments" do
    assert EditionWithImages.new.allows_image_attachments?
  end

  private

  def valid_edition_attributes
    {
      title:   'edition-title',
      body:    'edition-body',
      summary: 'edition-summary',
      creator: build(:user)
    }
  end
end
