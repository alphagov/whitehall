require 'test_helper'

class Whitehall::GovspeakRendererTest < ActiveSupport::TestCase
  test "Renders basic govspeak" do
    edition = build(:edition, body: 'Some content')

    assert_equivalent_html '<div class="govspeak"><p>Some content</p></div>',
      render_govspeak(edition)
  end

  test "interpolates images into rendered HTML" do
    image = OpenStruct.new(alt_text: "My Alt", url: "http://example.com/image.jpg")
    edition = build(:edition, body: "Some content with an image.\n\n!!1")
    edition.stubs(:images).returns([image])

    assert_equivalent_html govspeak_with_image_html(image),
      render_govspeak(edition)
  end

  test "converts inline attachments" do
    body = "#Heading\n\nText about my [InlineAttachment:2] and [InlineAttachment:1]."
    edition = build(:published_detailed_guide, :with_file_attachment, body: body, attachments: [
      attachment_1 = build(:file_attachment, id: 1),
      attachment_2 = build(:file_attachment, id: 2)
    ])
    html = render_govspeak(edition)
    assert_select_within_html html, "#attachment_#{attachment_1.id}"
    assert_select_within_html html, "#attachment_#{attachment_2.id}"
  end

  test "converts block attachments and handles thumbnails for PDFs" do
    body = "#Heading\n\nText. \n\n!@1\n\n Fooble"
    edition = create(:published_detailed_guide, :with_file_attachment, body: body, attachments: [
      attachment = build(:file_attachment, id: 1),
    ])

    # The content_type doesn't get set for some reason, so set it manually
    ad = edition.attachments.first.attachment_data
    ad.update_column(:content_type, 'application/pdf')

    html = render_govspeak(edition)
    assert_select_within_html html, "#attachment_#{attachment.id}"
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
