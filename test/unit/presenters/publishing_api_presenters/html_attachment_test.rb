require 'test_helper'

class PublishingApiPresenters::HtmlAttachmentTest < ActiveSupport::TestCase
  def present(record)
    PublishingApiPresenters::HtmlAttachment.new(record)
  end

  test "the constructor calls HtmlAttachment#render_govspeak!" do
    html_attachment = build(:html_attachment)
    html_attachment.govspeak_content.expects(:render_govspeak!)
    PublishingApiPresenters::HtmlAttachment.new(html_attachment)
  end

  test "HtmlAttachment presentation includes the correct values" do
    edition = create(:publication, :with_html_attachment, :published)
    html_attachment = HtmlAttachment.last

    expected_hash = {
      base_path: html_attachment.slug,
      content_id: html_attachment.content_id,
      title: html_attachment.title,
      schema_name: 'html_publication',
      document_type: 'html_publication',
      locale: 'en',
      public_updated_at: html_attachment.updated_at,
      update_type: 'major',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall',
      routes: [
        { path: html_attachment.url, type: 'exact' }
      ],
      redirects: [],
      details: {
        body: Whitehall::GovspeakRenderer.new
          .govspeak_to_html(html_attachment.govspeak_content.body),
        headings: html_attachment.govspeak_content.computed_headers_html,
        public_timestamp: edition.public_timestamp,
        first_published_version: html_attachment.attachable.first_published_version?,
      },
      need_ids: [],
      updated_at: html_attachment.updated_at
    }
    presented_item = present(html_attachment)

    assert_valid_against_schema(presented_item.content, 'html_publication')
    assert_valid_against_links_schema({ links: presented_item.links }, 'html_publication')

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
      presented_item.content[:details].delete(:body)

    assert_equal expected_hash[:details], presented_item.content[:details].except(:body)
  end
end
