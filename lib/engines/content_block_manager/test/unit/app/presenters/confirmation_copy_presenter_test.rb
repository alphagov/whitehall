require "test_helper"

class ContentBlockManager::ConfirmationCopyPresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:content_block_edition) { build(:content_block_edition, :email_address) }
  let(:block_type) { content_block_edition.block_type.humanize }

  let(:presenter) { ContentBlockManager::ConfirmationCopyPresenter.new(content_block_edition) }

  context "when the content block is scheduled" do
    let(:content_block_edition) { build(:content_block_edition, :email_address, scheduled_publication: Time.zone.now, state: :scheduled) }

    describe "#for_panel" do
      it "should return the scheduled text" do
        assert_equal "#{block_type} scheduled to publish on #{I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)}", presenter.for_panel
      end
    end

    describe "#for_paragraph" do
      it "should return the scheduled text" do
        assert_equal "You can now view the updated schedule of the content block.", presenter.for_paragraph
      end
    end
  end

  context "when there is more than one edition for the underlying document" do
    let(:document) { content_block_edition.document }

    before do
      document.expects(:editions).returns(
        build_list(:content_block_edition, 3, :email_address),
      )
    end

    describe "#for_panel" do
      it "should return the published text" do
        assert_equal "#{block_type} published", presenter.for_panel
      end
    end

    describe "#for_paragraph" do
      it "should return the published text" do
        assert_equal "You can now view the updated content block.", presenter.for_paragraph
      end
    end
  end

  context "when there is only one edition for the underlying document" do
    describe "#for_panel" do
      it "should return the created text" do
        assert_equal "#{block_type} created", presenter.for_panel
      end
    end

    describe "#for_paragraph" do
      it "should return the created text" do
        assert_equal "You can now view the content block.", presenter.for_paragraph
      end
    end
  end
end
