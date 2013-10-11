require 'test_helper'
require 'cleanups/supporting_page_attachment_fixer'

class SupportingPageAttachmentFixerTest < ActiveSupport::TestCase
  setup do
    @editor = create(:gds_editor)
    @null_logger = Logger.new(nil)
  end

  def excluded_attributes
    Cleanups::SupportingPageAttachmentFixer.new.ignored_attributes
  end

  def create_document_with_one_edition_missing_an_attachment!
    Timecop.freeze 2.weeks.ago do
      @first_edition = create(:published_policy)
      @supporting_page = create(:supporting_page, attachments: [], edition: @first_edition)
    end

    Timecop.freeze 1.week.ago do
      @second_edition = @first_edition.create_draft(@editor)
      @attachment = create(:attachment)
      @second_edition.supporting_pages.first.attachments = [@attachment]
      @second_edition.reload
      @second_edition.minor_change = true
    end

    Timecop.freeze 1.day.ago do
      EditionPublisher.new(@second_edition).perform!
    end

    # Create legacy associations
    SupportingPageAttachment.create!(attachment: @attachment, supporting_page: @first_edition.supporting_pages.first)
    SupportingPageAttachment.create!(attachment: @attachment, supporting_page: @second_edition.supporting_pages.first)

    @first_edition.reload
  end

  def create_document_with_no_missing_attachments!
    @first_edition = create(:published_policy)
    @attachment = create(:attachment)
    @supporting_page = create(:supporting_page, attachments: [@attachment], edition: @first_edition)

    # Create legacy associations
    SupportingPageAttachment.create!(attachment: @attachment, supporting_page: @first_edition.supporting_pages.first)

    @first_edition.reload
  end

  test "fix creates a duplicate attachment object for each missing legacy supporting page attachment" do
    create_document_with_one_edition_missing_an_attachment!

    Cleanups::SupportingPageAttachmentFixer.new(@null_logger).run!

    @first_edition.reload

    supporting_page = @first_edition.supporting_pages.first
    assert_equal 1, supporting_page.attachments.count
    assert_equal @attachment.attributes.except(*excluded_attributes), supporting_page.attachments.first.attributes.except(*excluded_attributes)
    refute_equal @attachment.id, supporting_page.attachments.first.id

    second_supporting_page = @second_edition.supporting_pages.first
    assert_equal [@attachment], second_supporting_page.attachments
  end

  test "show_problems displays a list of supporting pages with missing attachments" do
    create_document_with_one_edition_missing_an_attachment!

    problems = Cleanups::SupportingPageAttachmentFixer.new(@null_logger).show_problems

    assert_equal 1, problems.count
    assert_equal "#{@first_edition.id}: #{@attachment.id}", problems.first
  end

  test "show_problems does not report problems where no attachments are missing" do
    create_document_with_no_missing_attachments!

    problems = Cleanups::SupportingPageAttachmentFixer.new(@null_logger).show_problems

    assert_equal 0, problems.count
  end

end
