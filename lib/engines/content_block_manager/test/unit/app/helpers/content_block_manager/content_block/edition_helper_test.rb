require "test_helper"

class ContentBlockManager::ContentBlock::EditionHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include ERB::Util
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

  describe "#formatted_instructions_to_publishers" do
    test "it adds line breaks and links to instructions to publishers" do
      content_block_edition.instructions_to_publishers = "
        Hello
        There
        Here is a link: https://example.com
      "
      expected = "
      <p class=\"govuk-!-margin-top-0\">
        Hello <br />
        There <br />
        Here is a link: <a href=\"https://example.com\" class=\"govuk-link\" target=\"_blank\" rel=\"noopener\">https://example.com</a> <br />
      </p>
      "

      assert_equal expected.squish, formatted_instructions_to_publishers(content_block_edition).squish
    end
  end
end
