require "test_helper"

class ContentBlockManager::DeleteDraftContentBlocksWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include SidekiqTestHelpers

  # Suppress noisy Sidekiq logging in the test output
  setup do
    Sidekiq.configure_client do |cfg|
      cfg.logger.level = ::Logger::WARN
    end
  end

  describe "#perform" do
    it "deletes draft content block editions older than 60 days" do
      document = create(:content_block_document, :email_address)
      _published_editions = create_list(:content_block_edition, 2, :email_address, document:, state: :published)
      _drafts_younger_than_61_days = create_list(:content_block_edition, 2, :email_address, document:, state: :draft, created_at: 60.days.ago)
      draft_editions_older_than_61_days = create_list(:content_block_edition, 2, :email_address, document:, state: :draft, created_at: 61.days.ago)

      delete_service_mock = Minitest::Mock.new
      ContentBlockManager::DeleteEditionService.expects(:new).returns(delete_service_mock).at_least_once
      delete_service_mock.expect :call, nil, [draft_editions_older_than_61_days[0]]
      delete_service_mock.expect :call, nil, [draft_editions_older_than_61_days[1]]

      ContentBlockManager::DeleteDraftContentBlocksWorker.new.perform
      delete_service_mock.verify
    end

    it "will take the first 100 drafts to delete" do
      ar_mock = mock
      ContentBlockManager::ContentBlock::Edition.expects(:draft).returns(ar_mock)
      ar_mock.stubs(:where).with("created_at < ?", 60.days.ago).returns(ar_mock)
      ar_mock.expects(:limit).with(100).returns([])

      ContentBlockManager::DeleteDraftContentBlocksWorker.new.perform
    end

    it "returns without consequence if there are no draft editions" do
      document = create(:content_block_document, :email_address)
      create_list(:content_block_edition, 2, :email_address, document:, state: :published)

      ContentBlockManager::DeleteEditionService.expects(:new).never
      ContentBlockManager::DeleteEditionService.any_instance.expects(:call).never

      ContentBlockManager::DeleteDraftContentBlocksWorker.new.perform
    end
  end
end
