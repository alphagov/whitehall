require "test_helper"
require "rake"

class ImportTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable
    Sidekiq::Job.clear_all
  end

  describe "importing one document" do
    let(:task) { Rake::Task["import:news_article"] }

    test "it should call the DocumentImportWorker synchronously" do
      DocumentImportWorker.expects(:new).returns(stub(perform: true))
      task.invoke("test/fixtures/document_importer/example.json")
    end
  end

  describe "importing directory of documents" do
    let(:task) { Rake::Task["import:news_articles_in_directory"] }

    test "it should queue up the DocumentImportWorker for each file in the directory (asynchronously)" do
      DocumentImportWorker.expects(:perform_async).twice
      task.invoke("test/fixtures/document_importer")
    end
  end
end
