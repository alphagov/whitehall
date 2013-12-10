require 'test_helper'

class HtmlAttachmentTest < ActiveSupport::TestCase
  test '#url returns absolute path' do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    expected = "/government/publications/#{edition.slug}/#{attachment.slug}"
    assert_equal expected, attachment.url
  end

  test "slug is copied from previous edition's attachment" do
    edition = create(:published_publication, attachments: [
      attachment = build(:html_attachment, title: "an-html-attachment")
    ])
    draft = edition.create_draft(create(:policy_writer))

    assert_equal "an-html-attachment", draft.attachments.first.slug
  end

  test "slug is updated when the title is changed if edition is unpublished" do
    edition = create(:draft_publication, attachments: [
      attachment = build(:html_attachment, title: "an-html-attachment")
    ])

    attachment.title = "a-new-title"
    attachment.save
    attachment.reload

    assert_equal "a-new-title", attachment.slug
  end

  test "slug is not updated when the title is changed if edition is published" do
    edition = create(:published_publication, attachments: [
      build(:html_attachment, title: "an-html-attachment")
    ])
    draft = edition.create_draft(create(:policy_writer))
    attachment = draft.attachments.first

    attachment.title = "a-new-title"
    attachment.save
    attachment.reload

    assert_equal "an-html-attachment", attachment.slug
  end
end
