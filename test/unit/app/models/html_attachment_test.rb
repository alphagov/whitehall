require "test_helper"

class HtmlAttachmentTest < ActiveSupport::TestCase
  test "when HTML attachment is soft deleted, the associated Govspeak content remains intact" do
    attachment = create(:html_attachment)

    attachment.destroy! # this is a 'soft' delete
    attachment.reload

    assert attachment.deleted?
    assert attachment.govspeak_content.present?
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

  test "#url returns absolute path to the live site when not previewing" do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first

    expected = "https://www.test.gov.uk/government/publications/"
    expected += "#{edition.slug}/#{attachment.slug}"
    actual = attachment.url(full_url: true)

    assert_equal expected, actual
  end

  test "#url returns relative path by default" do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    assert_equal "/government/publications/#{edition.slug}/#{attachment.slug}", attachment.url
  end

  test "#url works when an attachment with english locale has special characters in title" do
    edition = create(:published_publication, :with_html_attachment)
    attachment = edition.attachments.first
    attachment.update!(locale: "en", title: "首次中英高级别安全对话成果声明")
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
    assert_equal "/government/statistics/#{statistics.slug}/#{attachment.slug}", attachment.url
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
    assert_equal "/government/consultations/#{consultation.slug}/outcome/#{attachment.slug}", attachment.url
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
    assert_equal "/government/consultations/#{consultation.slug}/public-feedback/#{attachment.slug}", attachment.url
  end

  test "#url works with call for evidence outcomes" do
    call_for_evidence = create(:call_for_evidence_with_outcome_html_attachment)
    attachment = call_for_evidence.outcome.attachments.first
    assert_equal "/government/calls-for-evidence/#{call_for_evidence.slug}/outcome/#{attachment.slug}", attachment.url
  end

  test "#url works when call for evidence has html attachment" do
    call_for_evidence = create(:call_for_evidence_with_html_attachment)
    attachment = call_for_evidence.attachments.first
    assert_equal "/government/calls-for-evidence/#{call_for_evidence.slug}/#{attachment.slug}", attachment.url
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

  test "slug is not created for non-english attachments if conversion to non-ASCII isn't possible" do
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

  test "slug is created even if the English title contains non-ASCII characters (since it's highly unlikely to be ALL non-ASCII characters like other languages)" do
    attachment = create(:html_attachment, locale: "en", title: "A page about copyright ©")

    expected_slug = "a-page-about-copyright"
    assert_equal expected_slug, attachment.slug
    assert_equal expected_slug, attachment.to_param
  end

  test "slug is created for non-english attachments where conversion to ASCII is possible" do
    attachment = create(:html_attachment, locale: "cs", title: "toto je náhodný název")

    expected_slug = "toto-je-nahodny-nazev"
    assert_equal expected_slug, attachment.slug
    assert_equal expected_slug, attachment.to_param
  end

  test "slug requires minimum 3 azAZ characters" do
    attachment = create(:html_attachment, locale: "cs", title: "tot")
    assert_equal nil, attachment.slug
  end

  test "slug reverts to nil, if document has never been published, if title is changed such that minimum 3 azAZ characters is not reached" do
    attachment = build(:html_attachment, title: "an-html-attachment")

    create(:draft_publication, attachments: [attachment])

    attachment.title = "foo"
    attachment.save!
    attachment.reload

    assert_equal nil, attachment.slug
  end

  test "even if slug is considered too short NOW, slug on legacy old attachment is not updated when the title is changed if document is published" do
    edition = create(
      :published_publication,
      attachments: [
        build(:html_attachment, title: "an-html-attachment"),
      ],
    )
    # Bypass validations and callbacks to manually set slug
    attachment = edition.attachments.first
    attachment.update_column(:slug, "foo")
    assert_equal "foo", attachment.slug

    #  now check slug not overridden
    draft = edition.create_draft(create(:writer))
    attachment = draft.attachments.first
    attachment.title = "a-new-title"
    attachment.save!
    attachment.reload
    assert_equal "foo", attachment.slug
  end

  # This behaviour is built into the friendly_id gem
  test "slug is made unique if there is an existing clash" do
    edition = create(
      :published_publication,
      attachments: [
        build(:html_attachment, locale: "en", title: "food"),
        build(:html_attachment, locale: "cs", title: "food"),
      ],
    )
    attachment_1 = edition.attachments.first
    attachment_2 = edition.attachments.last

    assert_equal "food", attachment_1.slug
    assert_equal "food--2", attachment_2.slug
  end

  test "#identifier falls back to content_id if no slug available" do
    attachment = create(:html_attachment)
    attachment.slug = nil
    assert_equal attachment.content_id, attachment.identifier
  end

  test "#identifier uses the slug if it's been set, irrespective of locale" do
    attachment = create(:html_attachment, locale: "cy")
    attachment.slug = "foo"
    assert_equal "foo", attachment.identifier
  end

  test "#translated_locales lists only the attachment's locale" do
    assert_equal %w[en], HtmlAttachment.new.translated_locales
    assert_equal %w[cy], HtmlAttachment.new(locale: "cy").translated_locales
  end

  test "#rendering_app returns government_frontend" do
    assert_equal "government-frontend", HtmlAttachment.new.rendering_app
  end
end
