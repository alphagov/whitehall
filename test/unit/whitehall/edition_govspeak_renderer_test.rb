require 'test_helper'

class Whitehall::EditionGovspeakRendererTest < ActiveSupport::TestCase
  test "Renders basic govspeak" do
    edition = build(:edition, body: 'Some content')

    assert_equivalent_html '<div class="govspeak"><p>Some content</p></div>',
      render_govspeak(edition).body
  end

  test "interpolates images into rendered HTML" do
    image = OpenStruct.new(alt_text: "My Alt", url: "http://example.com/image.jpg")
    edition = build(:edition, body: "Some content with an image.\n\n!!1")
    edition.stubs(:images).returns([image])

    assert_equivalent_html govspeak_with_image_html(image),
      render_govspeak(edition).body
  end

  test "converts inline attachments" do
    body = "#Heading\n\nText about my [InlineAttachment:2] and [InlineAttachment:1]."
    edition = build(:published_detailed_guide, :with_file_attachment, body: body, attachments: [
      attachment_1 = build(:file_attachment, id: 1),
      attachment_2 = build(:file_attachment, id: 2)
    ])
    html = render_govspeak(edition).body
    assert_select_within_html html, "#attachment_#{attachment_1.id}"
    assert_select_within_html html, "#attachment_#{attachment_2.id}"
  end

  test "renders unpublishing explanation as govspeak" do
    edition = create(:unpublishing, explanation: 'Some explanation').edition
    assert_equivalent_html '<div class="govspeak"><p>Some explanation</p></div>',
      render_govspeak(edition).unpublishing_explanation
  end

  def render_govspeak(edition)
    Whitehall::EditionGovspeakRenderer.new(edition)
  end

private

  def govspeak_with_image_html(image)
    <<-END
      <div class="govspeak">
        <p>Some content with an image.</p>

        <figure class="image embedded">
          <div class="img">
            <img alt="#{image.alt_text}" src="#{Whitehall.asset_root}#{image.url}">
          </div>
        </figure>
      </div>
    END
  end
end
