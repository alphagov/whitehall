require "test_helper"

class Whitehall::GovspeakRendererTest < ActiveSupport::TestCase
  test "Renders basic govspeak" do
    edition = build(:edition, body: "Some content")

    assert_equivalent_html '<div class="govspeak"><p>Some content</p></div>',
                           render_govspeak(edition)
  end

  test "interpolates images into rendered HTML when using !!number as a markdown" do
    image_data = create(:image_data, id: 1)
    image = OpenStruct.new(alt_text: "My Alt", url: "http://example.com/image.jpg", image_data: ImageData.find(image_data.id))
    edition = build(:edition, body: "Some content with an image.\n\n!!1")
    edition.stubs(:images).returns([image])

    assert_equivalent_html govspeak_with_image_html(image),
                           render_govspeak(edition)
  end

  test "interpolates images into rendered HTML when using filename as a markdown" do
    image_data = create(:image_data, id: 1)
    image = OpenStruct.new(alt_text: "My Alt", url: "http://example.com/image.jpg", image_data: ImageData.find(image_data.id))
    edition = build(:edition, body: "Some content with an image.\n\n[Image: minister-of-funk.960x640.jpg]")
    edition.stubs(:images).returns([image])

    assert_equivalent_html govspeak_with_image_html(image),
                           render_govspeak(edition)
  end

  test "converts inline attachments" do
    body = "#Heading\n\nText about my [AttachmentLink:greenpaper.pdf] and [AttachmentLink:greenpaper.pdf]."
    edition = build(
      :published_detailed_guide,
      :with_file_attachment,
      body:,
      attachments: [
        build(:file_attachment, title: "file-attachment-title-1"),
        build(:file_attachment, title: "file-attachment-title-2"),
      ],
    )
    html = render_govspeak(edition)

    assert_select_within_html html, ".gem-c-attachment-link", count: 2
  end

  test "converts block attachments and handles thumbnails for PDFs" do
    body = "#Heading\n\nText. \n\n!@1\n\n Fooble"
    edition = create(
      :published_detailed_guide,
      :with_file_attachment,
      body:,
      attachments: [
        build(:file_attachment, id: 1),
      ],
    )

    # The content_type doesn't get set for some reason, so set it manually
    ad = edition.attachments.first.attachment_data
    ad.update_column(:content_type, "application/pdf")

    html = render_govspeak(edition)
    assert_select_within_html html, "a[href='#{edition.attachments.first.url}']"
  end

  def render_govspeak(edition)
    Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(edition)
  end

private

  def govspeak_with_image_html(image)
    <<-HTML
      <div class="govspeak">
        <p>Some content with an image.</p>

        <figure class="image embedded">
          <div class="img">
            <img alt="#{image.alt_text}" src="#{image.url}">
          </div>
        </figure>
      </div>
    HTML
  end
end
