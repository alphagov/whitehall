require "test_helper"

class HtmlAttachmentTest < ActiveSupport::TestCase
  test "associated govspeak content is deleted with the html attachment" do
    attachment = create(:html_attachment)
    govspeak_content = attachment.govspeak_content

    attachment.destroy!

    assert_not GovspeakContent.exists?(govspeak_content.id)
  end

  test "#deep_clone deep clones the HTML attachment, body, content_id and slug" do
    attachment = create(:html_attachment)

    clone = attachment.deep_clone

    assert attachment.id != clone.id
    assert clone.new_record?
    assert_equal attachment.title, clone.title
    assert_equal attachment.body, clone.body
    assert_equal attachment.slug, clone.slug
    assert_equal attachment.content_id, clone.content_id
  end

  test "#url returns absolute path to the draft stack when previewing" do
    edition = create(:draft_publication, :with_html_attachment)
    attachment = edition.attachments.first

    expected = "https://draft-origin.test.gov.uk/government/publications/"
    expected += "#{edition.slug}/#{attachment.slug}?preview=#{attachment.id}"
    actual = attachment.url(preview: true, full_url: true)

    assert_equal expected, actual
  end

  test "#url returns absolute path to the draft stack when previewing with a cachebust" do
    edition = create(:draft_publication, :with_html_attachment)
    attachment = edition.attachments.first

    expected = "https://draft-origin.test.gov.uk/government/publications/"
    expected += "#{edition.slug}/#{attachment.slug}?cachebust=123&preview=#{attachment.id}"
    actual = attachment.url(preview: true, full_url: true, cachebust: "123")

    assert_equal expected, actual
  end

  test "#url returns absolute path to the draft stack when previewing for non-english locale" do
    edition = create(:draft_publication, :with_html_attachment)
    attachment = edition.attachments.first
    attachment.update!(locale: "fi")

    expected = "https://draft-origin.test.gov.uk/government/publications/"
    expected += "#{edition.slug}/#{attachment.content_id}?preview=#{attachment.id}"
    actual = attachment.url(preview: true, full_url: true)

    assert_equal expected, actual
  end

  test "#url returns absolute path to the live site when not previewing" do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first

    expected = "https://www.test.gov.uk/government/publications/"
    expected += "#{edition.slug}/#{attachment.slug}"
    actual = attachment.url(full_url: true)

    assert_equal expected, actual
  end

  test "#url returns absolute path to the live site when not previewing for non-english locale" do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    attachment.update!(locale: "fi")

    expected = "https://www.test.gov.uk/government/publications/"
    expected += "#{edition.slug}/#{attachment.content_id}"
    actual = attachment.url(full_url: true)

    assert_equal expected, actual
  end

  test "#url returns relative path by default" do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    assert_equal "/government/publications/#{edition.slug}/#{attachment.slug}", attachment.url
  end

  test "#url returns relative path by default for non-english locale" do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    attachment.update!(locale: "fi")
    assert_equal "/government/publications/#{edition.slug}/#{attachment.content_id}", attachment.url
  end

  test "#url works with statistics" do
    statistics = create(:published_national_statistics)
    attachment = statistics.attachments.last
    assert_equal "/government/statistics/#{statistics.slug}/#{attachment.slug}", attachment.url
  end

  test "#url works with statistics for non-english locale" do
    statistics = create(:published_national_statistics)
    attachment = statistics.attachments.last
    attachment.update!(locale: "fi")
    assert_equal "/government/statistics/#{statistics.slug}/#{attachment.content_id}", attachment.url
  end

  test "#url works with consultation outcomes" do
    consultation = create(:consultation_with_outcome_html_attachment)
    attachment = consultation.outcome.attachments.first
    assert_equal "/government/consultations/#{consultation.slug}/outcome/#{attachment.slug}", attachment.url
  end

  test "#url works with consultation outcomes for non-english locale" do
    consultation = create(:consultation_with_outcome_html_attachment)
    attachment = consultation.outcome.attachments.first
    attachment.update!(locale: "fi")
    assert_equal "/government/consultations/#{consultation.slug}/outcome/#{attachment.content_id}", attachment.url
  end

  test "#url works with consultation public feedback" do
    consultation = create(:consultation_with_public_feedback_html_attachment)
    attachment = consultation.public_feedback.attachments.first
    assert_equal "/government/consultations/#{consultation.slug}/public-feedback/#{attachment.slug}", attachment.url
  end

  test "#url works with consultation public feedback for non-english locale" do
    consultation = create(:consultation_with_public_feedback_html_attachment)
    attachment = consultation.public_feedback.attachments.first
    attachment.update!(locale: "fi")
    assert_equal "/government/consultations/#{consultation.slug}/public-feedback/#{attachment.content_id}", attachment.url
  end

  test "#url works with call for evidence outcomes" do
    call_for_evidence = create(:call_for_evidence_with_outcome_html_attachment)
    attachment = call_for_evidence.outcome.attachments.first
    assert_equal "/government/calls-for-evidence/#{call_for_evidence.slug}/outcome/#{attachment.slug}", attachment.url
  end

  test "slug is copied from previous edition's attachment" do
    edition = create(
      :published_publication,
      attachments: [
        build(:html_attachment, title: "an-html-attachment"),
      ],
    )
    draft = edition.create_draft(create(:writer))

    assert_equal "an-html-attachment", draft.attachments.first.slug
  end

  test "slug is updated when the title is changed if document has never been published" do
    attachment = build(:html_attachment, title: "an-html-attachment")

    create(:draft_publication, attachments: [attachment])

    attachment.title = "a-new-title"
    attachment.save!
    attachment.reload

    assert_equal "a-new-title", attachment.slug
  end

  test "slug on old attachment is not updated when the title is changed if document is published" do
    edition = create(
      :published_publication,
      attachments: [
        build(:html_attachment, title: "an-html-attachment"),
      ],
    )
    draft = edition.create_draft(create(:writer))
    attachment = draft.attachments.first

    attachment.title = "a-new-title"
    attachment.save!
    attachment.reload

    assert_equal "an-html-attachment", attachment.slug
  end

  test "slug on new attachment is updated when the title is changed if document is published" do
    edition = create(
      :published_publication,
    )
    draft = edition.create_draft(create(:writer))
    attachment = build(:html_attachment, title: "an-html-attachment")
    draft.attachments = [attachment]

    attachment.title = "a-new-title"
    attachment.save!
    attachment.reload

    assert_equal "a-new-title", attachment.slug
  end

  test "slug is not updated when the title has been changed in a prior published edition" do
    edition = create(
      :published_publication,
      attachments: [
        build(:html_attachment, title: "an-html-attachment"),
      ],
    )
    draft = edition.create_draft(create(:writer))
    attachment = draft.attachments.first

    attachment.title = "a-new-title"
    attachment.save!
    attachment.reload

    draft.change_note = "Edited HTML attachment title"
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

    attachment.update!(locale: "fr")
    assert attachment.slug.blank?
  end

  test "#translated_locales lists only the attachment's locale" do
    assert_equal %w[en], HtmlAttachment.new.translated_locales
    assert_equal %w[cy], HtmlAttachment.new(locale: "cy").translated_locales
  end

  test "#rendering_app returns government_frontend" do
    assert_equal "government-frontend", HtmlAttachment.new.rendering_app
  end
end
