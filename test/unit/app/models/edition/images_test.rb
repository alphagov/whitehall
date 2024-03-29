require "test_helper"

class Edition::ImagesTest < ActiveSupport::TestCase
  class EditionWithImages < Edition
    include ::Edition::Images

    def previously_published
      false
    end

    def lead_image; end

    def build_edition_lead_image(args)
      EditionLeadImage.new(edition: self, **args)
    end

    def can_have_custom_lead_image?; end
  end

  include ActionDispatch::TestProcess

  test "editions can be created with multiple images" do
    edition = EditionWithImages.create!(
      valid_edition_attributes.merge(
        images_attributes: [
          {
            alt_text: "Something about this image",
            caption: "Text to be visible along with the image",
            image_data_attributes: {
              file: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
            },
          },
          {
            alt_text: "alt-text-2",
            caption: "caption-2",
            image_data_attributes: {
              file: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
            },
          },
        ],
      ),
    )

    assert_equal 2, edition.images.count
    assert_equal "Something about this image", edition.images[0].alt_text
    assert_equal "Text to be visible along with the image", edition.images[0].caption
    assert_equal "alt-text-2", edition.images[1].alt_text
    assert_equal "caption-2", edition.images[1].caption
  end

  test "#create_draft should include copies of image attributes" do
    image = create(:image, caption: "image-caption")
    published_edition = EditionWithImages.create!(
      valid_edition_attributes.merge(
        state: "published",
        major_change_published_at: Time.zone.now,
        first_published_at: Time.zone.now,
        images: [image],
      ),
    )

    draft_edition = published_edition.create_draft(build(:user))
    draft_edition.change_note = "change-note"

    assert draft_edition.valid?

    new_image = draft_edition.images.last
    assert_not_equal image, new_image
    assert_equal image.alt_text, new_image.alt_text
    assert_equal image.caption, new_image.caption
  end

  test "#create_draft should not duplicate the actual image data" do
    image = create(:image)
    published_edition = EditionWithImages.create!(
      valid_edition_attributes.merge(
        state: "published",
        major_change_published_at: Time.zone.now,
        first_published_at: Time.zone.now,
        images: [image],
      ),
    )

    draft_edition = published_edition.create_draft(build(:user))
    new_image = draft_edition.images.last

    assert_equal image.image_data_id, new_image.image_data_id
  end

  test "#create_draft should carry-over images even when there are validation errors in image data" do
    published_edition = EditionWithImages.new(
      valid_edition_attributes.merge(
        state: "published",
        document: create(:document),
        major_change_published_at: Time.zone.now,
        first_published_at: Time.zone.now,
        images_attributes: [{
          alt_text: "image smaller than 960x640",
          caption: "some-caption",
          image_data_attributes: {
            file: upload_fixture("horrible-image.64x96.jpg", "image/jpg"),
          },
        }],
      ),
    )
    published_edition.save!(validate: false)

    new_draft = published_edition.create_draft(build(:user))
    new_draft.reload

    assert_equal 1, new_draft.images.count
    assert_equal new_draft.images.first.image_data, published_edition.images.first.image_data
  end

  test "#create_draft should create a new edition_lead_image correctly when a lead image is present on the published_edition" do
    image1 = create(:image)
    image2 = create(:image)

    published_edition = EditionWithImages.create!(
      valid_edition_attributes.merge(
        state: "published",
        major_change_published_at: Time.zone.now,
        first_published_at: Time.zone.now,
        images: [image1, image2],
      ),
    )
    published_edition.stubs(:lead_image).returns(image2)
    published_edition.stubs(:can_have_custom_lead_image?).returns(true)

    draft_edition = published_edition.create_draft(build(:user))
    edition_lead_image = EditionLeadImage.find_by!(edition_id: draft_edition.id)

    assert_not_equal image2.id, edition_lead_image.image_id
    assert_equal image2.reload.image_data.images.last.id, edition_lead_image.image_id
  end

  test "captions for images can be changed between versions" do
    published_edition = EditionWithImages.new(
      valid_edition_attributes.merge(
        state: "published",
        major_change_published_at: Time.zone.now,
        first_published_at: Time.zone.now,
        images_attributes: [{
          alt_text: "alt-text",
          caption: "original-caption",
          image_data_attributes: {
            file: upload_fixture("minister-of-funk.960x640.jpg", "image/jpg"),
          },
        }],
      ),
    )
    published_edition.images.first.image_data = build(:image_data)
    published_edition.save!
    draft_edition = published_edition.create_draft(build(:user))
    draft_edition.images.first.update!(caption: "new-caption")

    assert_equal "original-caption", published_edition.images.first.caption
  end

  test "#destroy should also remove the image" do
    image = create(:image)
    edition = EditionWithImages.create!(valid_edition_attributes.merge(images: [image]))
    edition.destroy!
    assert_not Image.find_by(id: image.id)
  end

  test "should indicate that it allows image attachments" do
    assert EditionWithImages.new.allows_image_attachments?
  end

private

  def valid_edition_attributes
    {
      title: "edition-title",
      body: "edition-body",
      summary: "edition-summary",
      creator: build(:user),
    }
  end
end
