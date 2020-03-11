require "test_helper"

class AttachmentAttributeUpdaterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe DataHygiene::AttachmentAttributeUpdater do
    let(:attachment) { build(:file_attachment, attachment_data: build(:attachment_data), command_paper_number: original_command_paper_number) }

    def call_attachment_attribute_updater
      DataHygiene::AttachmentAttributeUpdater.call(attachment, dry_run: dry_run)
    end

    context "during a dry run" do
      let(:dry_run) { true }
      let(:original_command_paper_number) { "CM123" }
      let(:new_paper_number) { "Cm. 123" }

      it "doesn't update the command paper number" do
        call_attachment_attribute_updater
        assert_equal(attachment.command_paper_number, original_command_paper_number)
      end

      it "does return what the command paper number should be" do
        new_number = call_attachment_attribute_updater
        assert_equal(new_number, new_paper_number)
      end
    end

    context "during a real run" do
      let(:dry_run) { false }
      let(:original_command_paper_number) { "CM123" }
      let(:new_paper_number) { "Cm. 123" }

      it "does update the command paper number" do
        call_attachment_attribute_updater
        assert_equal(attachment.command_paper_number, new_paper_number)
      end

      context "given a command paper number beginning with CP" do
        let(:original_command_paper_number) { "cp . 123" }

        it "omits the period and retains the uppercasing" do
          call_attachment_attribute_updater
          assert_equal(attachment.command_paper_number, "CP 123")
        end
      end

      context "given a command paper number with a suffix" do
        let(:original_command_paper_number) { "cM 123- iV" }

        it "uppercases the suffix" do
          call_attachment_attribute_updater
          assert_equal(attachment.command_paper_number, "Cm. 123-IV")
        end
      end

      context "given a command paper number it cannot fix" do
        let(:original_command_paper_number) { "Cmd 123-1" }

        it "raises an exception" do
          assert_raises DataHygiene::AttachmentAttributeNotFixable do
            call_attachment_attribute_updater
          end
        end
      end
    end
  end
end
