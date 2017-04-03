require 'test_helper'

class PublishingApi::HtmlAttachmentPresenterTest < ActiveSupport::TestCase
  def present(record)
    PublishingApi::HtmlAttachmentPresenter.new(record)
  end

  test "the constructor calls HtmlAttachment#render_govspeak!" do
    html_attachment = build(:html_attachment)
    html_attachment.govspeak_content.expects(:render_govspeak!)
    PublishingApi::HtmlAttachmentPresenter.new(html_attachment)
  end

  test "HtmlAttachment presentation includes the correct values" do
    edition = create(:publication, :with_html_attachment, :published)
    html_attachment = HtmlAttachment.last

    expected_hash = {
      base_path: "/government/publications/#{edition.document.slug}/#{html_attachment.slug}",
      title: html_attachment.title,
      description: nil,
      schema_name: 'html_publication',
      document_type: 'html_publication',
      locale: 'en',
      public_updated_at: html_attachment.updated_at,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
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
      need_ids: []
    }
    presented_item = present(html_attachment)

    assert_valid_against_schema(presented_item.content, 'html_publication')
    assert_valid_against_links_schema({ links: presented_item.links }, 'html_publication')

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    presented_content = presented_item.content
    assert_equivalent_html expected_hash[:details].delete(:body),
      presented_content[:details].delete(:body)

    expected_content = expected_hash.merge(links: presented_item.links)
    assert_equal expected_content, presented_content

    %i(organisations parent).each { |k| assert_includes(expected_content[:links].keys, k) }
  end

  test "HtmlAttachment presentation includes the correct locale" do
    create(:publication, :with_html_attachment, :published)

    html_attachment = HtmlAttachment.last
    html_attachment.locale = "cy"

    assert_equal "cy", present(html_attachment).content[:locale]
  end

  test "HtmlAttachment presentations sends an empty body if there's no govspeak" do
    create(:publication, :with_html_attachment, :published)

    GovspeakContent.delete_all
    html_attachment = HtmlAttachment.last

    assert_equal "", present(html_attachment).content[:details][:body]
    assert_equal "", present(html_attachment).content[:details][:headings]
  end

  test "HtmlAttachment presentations sends the parent updated_at if it has no public_timestamp" do
    Timecop.freeze do
      create(:publication, :with_html_attachment, :draft)

      GovspeakContent.delete_all
      html_attachment = HtmlAttachment.last

      assert_equal Time.zone.now, present(html_attachment).content[:details][:public_timestamp]
    end
  end

  test "HtmlAttachment presents unique organisation content_ids" do
    create(:publication, :with_html_attachment, :published)

    html_attachment = HtmlAttachment.last
    # if an organisation has multiple translations, pluck returns
    # duplicate content_ids because it constructs a left outer join
    html_attachment.attachable.organisations.expects(:pluck).with(:content_id).returns(%w(abcdef abcdef))

    assert_equal ["abcdef"], present(html_attachment).links[:organisations]
  end
end
