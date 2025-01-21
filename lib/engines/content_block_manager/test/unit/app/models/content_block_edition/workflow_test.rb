require "test_helper"

class ContentBlockManager::WorkflowTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "transitions" do
    it "sets draft as the default state" do
      edition = create(:content_block_edition, document: create(:content_block_document, block_type: "email_address"))
      assert edition.draft?
    end

    it "transitions a scheduled edition into the published state when publishing" do
      edition = create(:content_block_edition,
                       document: create(
                         :content_block_document,
                         block_type: "email_address",
                       ),
                       scheduled_publication: 7.days.since(Time.zone.now).to_date,
                       state: "scheduled")
      edition.publish!
      assert edition.published?
    end

    it "transitions into the scheduled state when scheduling" do
      edition = create(:content_block_edition,
                       scheduled_publication: 7.days.since(Time.zone.now).to_date,
                       document: create(
                         :content_block_document,
                         block_type: "email_address",
                       ))
      edition.schedule!
      assert edition.scheduled?
    end

    it "transitions into the superseded state when superseding" do
      edition = create(:content_block_edition, :email_address, scheduled_publication: 7.days.since(Time.zone.now).to_date, state: "scheduled")
      edition.supersede!
      assert edition.superseded?
    end
  end

  describe "validation" do
    let(:content_block_document) { build(:content_block_document) }
    let(:content_block_edition) { build(:content_block_edition, document: content_block_document) }

    it "validates when the state is scheduled" do
      ContentBlockManager::ScheduledPublicationValidator.any_instance.expects(:validate)

      content_block_edition.state = "scheduled"
      content_block_edition.valid?
    end

    it "does not validate when the state is not scheduled" do
      ContentBlockManager::ScheduledPublicationValidator.any_instance.expects(:validate).never

      content_block_edition.state = "draft"
      content_block_edition.valid?
    end

    it "validates when the validation scope is set to scheduling" do
      ContentBlockManager::ScheduledPublicationValidator.any_instance.expects(:validate)

      content_block_edition.state = "draft"
      content_block_edition.valid?(:scheduling)
    end
  end
end
