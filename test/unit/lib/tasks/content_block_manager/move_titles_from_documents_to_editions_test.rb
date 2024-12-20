require "test_helper"
require "rake"

class MoveTitlesFromDocumentsToEditionsRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#move_title_from_documents_to_editions" do
    describe "default dry run feature" do
      let(:task) { Rake::Task["move_titles_from_documents_to_editions"] }
      let(:documents) { create_list(:content_block_document, 3, :email_address) }
      let(:dry_run_output) do
        "This was a dry run. Titles would have been changed from 3 documents to 6 editions."
      end
      let(:confirmation_output) do
        "Titles were changed from 3 documents to 6 editions."
      end

      it "logs an ouput for the title changes that would be made" do
        documents.each_with_index do |document, index|
          document.update!(title: "document_title_#{index}")
          create(:content_block_edition, document:)
          create(:content_block_edition, document:)
        end
        log_output = ""
        documents.each do |document|
          log_output += document.editions.collect { |edition|
            "Edition title set to #{edition.document.title} for Edition #{edition.id}"
          }.join("\\n")
          log_output += "\\n"
        end
        assert_output(/#{log_output}#{dry_run_output}/) { task.invoke("dry_run") }
      end
    end
  end
end
