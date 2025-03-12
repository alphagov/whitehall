require "test_helper"

class ContentBlockManager::ContentBlock::EditionHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include ContentBlockManager::ContentBlock::EditionHelper

  let(:content_block_edition) do
    build(:content_block_edition,
          updated_at: Time.zone.now - 2.days,
          scheduled_publication: Time.zone.now + 3.days)
  end

  describe "#published_date" do
    it "calls the time tag helper with the `updated_at` value of the edition" do
      tag.expects(:time).with(
        content_block_edition.updated_at.to_fs(:long_ordinal_with_at),
        class: "date",
        datetime: content_block_edition.updated_at.iso8601,
        lang: "en",
      ).returns("STUB")

      assert_equal "STUB", published_date(content_block_edition)
    end
  end

  describe "#scheduled_date" do
    it "calls the time tag helper with the `scheduled_publication` value of the edition" do
      tag.expects(:time).with(
        content_block_edition.scheduled_publication.to_fs(:long_ordinal_with_at),
        class: "date",
        datetime: content_block_edition.scheduled_publication.iso8601,
        lang: "en",
      ).returns("STUB")

      assert_equal "STUB", scheduled_date(content_block_edition)
    end
  end
end
