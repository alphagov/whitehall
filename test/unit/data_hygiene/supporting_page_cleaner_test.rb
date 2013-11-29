require 'test_helper'
require 'data_hygiene/supporting_page_cleaner'

class SupportingPageCleanerTest < ActiveSupport::TestCase

  test "destroys duplicate superseded supporting pages and their attachments" do
    first_edition     = create_migrated_supporting_page(:superseded, body: 'original body', title: 'original title')
    dup1_edition      = duplicate_migrated_supportig_page(first_edition)
    second_edition    = duplicate_migrated_supportig_page(dup1_edition, state: :superseded, body: 'Body was updated')
    create(:file_attachment, attachable: second_edition)

    dup2_edition      = duplicate_migrated_supportig_page(second_edition)
    dup3_edition      = duplicate_migrated_supportig_page(dup2_edition, state: :superseded, title: 'Title updated')
    published_edition = duplicate_migrated_supportig_page(dup3_edition, state: :published)
    draft_edition     = published_edition.create_draft(create(:policy_writer))

    first_attachment  = second_edition.reload.attachments.first
    dup2_attachment   = dup2_edition.reload.attachments.first
    dup3_attachment   = dup3_edition.reload.attachments.first
    pub_attachment    = published_edition.reload.attachments.first
    draft_attachment  = draft_edition.reload.attachments.first


    cleaner = SupportingPageCleaner.new(published_edition.document)
    cleaner.delete_duplicate_superseded_editions!

    refute SupportingPage.exists? dup1_edition
    refute SupportingPage.exists? dup2_edition
    refute SupportingPage.exists? dup3_edition

    assert SupportingPage.exists? first_edition
    assert SupportingPage.exists? second_edition
    assert SupportingPage.exists? published_edition
    assert SupportingPage.exists? draft_edition

    refute Attachment.exists? dup2_attachment
    refute Attachment.exists? dup3_attachment

    assert Attachment.exists? first_attachment
    assert Attachment.exists? pub_attachment
    assert Attachment.exists? draft_attachment
  end

private

  def create_migrated_supporting_page(state, attributes={})
    create(:supporting_page, state, attributes).tap do |edition|
      EditionedSupportingPageMapping.create!(new_supporting_page_id: edition.id)
    end
  end

  def duplicate_migrated_supportig_page(original, options={})
    body  ||= options.fetch(:body, original.body)
    title ||= options.fetch(:title, original.title)
    state ||= options.fetch(:state, original.current_state)

    create_migrated_supporting_page(state, body: body, title: title, document: original.document, related_policies: original.related_policies).tap do |edition|
      original.attachments(true).each { |attachment| edition.attachments << attachment.class.new(attachment.attributes) }
    end
  end
end
