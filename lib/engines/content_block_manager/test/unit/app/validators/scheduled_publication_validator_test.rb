require "test_helper"

class ContentBlockManager::ScheduledPublicationValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_document) { build(:content_block_document, :email_address) }
  let(:content_block_edition) { build(:content_block_edition, document: content_block_document, state: "scheduled") }

  it "validates if scheduled_publication is blank" do
    content_block_edition.scheduled_publication = nil

    assert_equal false, content_block_edition.valid?

    assert_equal [I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.scheduled_publication.blank")], content_block_edition.errors.full_messages
  end

  it "validates if scheduled_publication is in the past" do
    content_block_edition.scheduled_publication = Time.zone.now - 2.days

    assert_equal false, content_block_edition.valid?

    assert_equal [I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.scheduled_publication.future_date")], content_block_edition.errors.full_messages
  end

  it "is valid if a future date is set" do
    content_block_edition.scheduled_publication = Time.zone.now + 2.days

    assert_equal true, content_block_edition.valid?
  end
end
