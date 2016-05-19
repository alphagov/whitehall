# encoding: utf-8

require 'test_helper'

class HtmlAttachmentTest < ActiveSupport::TestCase
  test '#govspeak_content_body_html returns the computed HTML as an HTML safe string' do
    attachment = create(:html_attachment, body: 'Some govspeak')

    assert attachment.reload.govspeak_content_body_html.html_safe?
    assert_equivalent_html "<div class=\"govspeak\"><p>Some govspeak</p></div>",
      attachment.govspeak_content_body_html
  end

  test 'associated govspeak content is deleted with the html attachment' do
    attachment = create(:html_attachment)
    govspeak_content = attachment.govspeak_content

    attachment.destroy

    refute GovspeakContent.exists?(govspeak_content.id)
  end

  test '#deep_clone deep clones the HTML attachment, body and slug' do
    attachment = create(:html_attachment)

    clone = attachment.deep_clone

    assert attachment.id != clone.id
    assert clone.new_record?
    assert_equal attachment.title, clone.title
    assert_equal attachment.govspeak_content_body, clone.govspeak_content_body
    assert_equal attachment.slug, clone.slug
  end

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
    draft = edition.create_draft(create(:writer))

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
    draft = edition.create_draft(create(:writer))
    attachment = draft.attachments.first

    attachment.title = "a-new-title"
    attachment.save
    attachment.reload

    assert_equal "an-html-attachment", attachment.slug
  end

  test "slug is not updated when the title has been changed in a prior published edition" do
    edition = create(:published_publication, attachments: [
      build(:html_attachment, title: "an-html-attachment")
    ])
    draft = edition.create_draft(create(:writer))
    attachment = draft.attachments.first

    attachment.title = "a-new-title"
    attachment.save
    attachment.reload

    draft.change_note = 'Edited HTML attachment title'
    force_publish(draft)

    second_draft = draft.create_draft(create(:writer))
    second_draft_attachment = second_draft.attachments.first

    assert_equal "an-html-attachment", attachment.slug
    assert_equal "an-html-attachment", second_draft_attachment.slug
  end

  test "slug is not created for non-english attachments" do
    # Additional attachment to ensure the duplicate detection behaviour isn't triggered
    create(:html_attachment, locale: "fr")
    attachment = create(:html_attachment, locale: "ar", title: "المملكة المتحدة والمملكة العربية السعودية")

    assert attachment.slug.blank?
    assert_equal attachment.id.to_s, attachment.to_param
  end

  test "slug is created for english-only attachments" do
    attachment = create(:html_attachment, locale: "en", title: "We have a bias for action")

    expected_slug = "we-have-a-bias-for-action"
    assert_equal expected_slug, attachment.slug
    assert_equal expected_slug, attachment.to_param
  end

  test "slug is cleared when changing from english to non-english" do
    attachment = create(:html_attachment, locale: "en")

    attachment.update_attributes!(locale: "fr")
    assert attachment.slug.blank?
  end

  test "#save_and_update_publishing_api saves the attachment" do
    build(
      :draft_publication,
      html_attachments: [attachment = build(:html_attachment)]
    )
    attachment.save_and_update_publishing_api
    assert attachment.persisted?, "Attachment has not been saved"
  end

  test "#save_and_udpate_publishing_api sends the attachable to draft_updater" do
    edition = create(
      :draft_publication,
      html_attachments: [attachment = build(:html_attachment)]
    )

    Whitehall.edition_services
      .expects(:draft_updater)
      .with(edition)
      .returns(draft_updater = stub)
    draft_updater.expects(:perform!)

    attachment.save_and_update_publishing_api
  end
end
