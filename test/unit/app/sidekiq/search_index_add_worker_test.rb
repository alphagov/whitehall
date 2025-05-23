require "test_helper"

class SearchIndexAddWorkerTest < ActiveSupport::TestCase
  test "#perform raises an exception if the class is not searchable" do
    Object.stub_const("NonSearchableClass", Class.new) do
      worker = SearchIndexAddWorker.new
      e = assert_raise(ArgumentError) { worker.perform("NonSearchableClass", 1) }
      assert_match %r{is not a searchable class}, e.message
    end
  end

  test "#perform logs a warning if the instance does not exist" do
    Sidekiq.logger.expects(:warn).once
    SearchIndexAddWorker.new.perform("Organisation", 1)
  end

  test "#perform indexes searchable instances" do
    organisation = create(:organisation)
    attributes_for_indexing_mock = mock

    Organisation.any_instance.stubs(:search_index).returns(attributes_for_indexing_mock)
    Whitehall::SearchIndex.indexer_class.any_instance.expects(:add).with(attributes_for_indexing_mock)
    SearchIndexAddWorker.new.perform(organisation.class.name, organisation.id)
  end

  test "#perform does not index non-searchable instances and logs a warning" do
    announcement = create(:statistics_announcement, publication: create(:published_publication, publication_type: PublicationType::OfficialStatistics))

    Whitehall::SearchIndex.indexer_class.any_instance.expects(:add).never
    Sidekiq.logger.expects(:warn).once
    SearchIndexAddWorker.new.perform(announcement.class.name, announcement.id)
  end
end
