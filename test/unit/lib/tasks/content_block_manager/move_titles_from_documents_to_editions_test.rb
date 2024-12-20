require "test_helper"
require "rake"

class MoveTitlesFromDocumentsToEditionsRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#move_title_from_documents_to_editions" do
    let(:task) { Rake::Task["move_titles_from_documents_to_editions"] }
    let(:documents) { create_list(:content_block_document, 3, :email_address) }
    let(:schemas) { build_list(:content_block_schema, 1, block_type: "email_address", body: { "properties" => {} }) }

    def log_output
      log_output = ""
      documents.each do |document|
        log_output += document.editions.collect { |edition|
          "Edition title set to #{edition.document.title} for Edition #{edition.id}"
        }.join("\\n")
        log_output += "\\n"
      end
      log_output
    end

    before do
      documents.each_with_index do |document, index|
        document.update!(title: "document_title_#{index}")
        create(:content_block_edition, document:)
        create(:content_block_edition, document:)
      end

      ContentBlockManager::ContentBlock::Schema.stubs(:all).returns(schemas)
    end

    describe "default dry run feature" do
      let(:dry_run_output) do
        "This was a dry run. Titles would have been changed from 3 documents to 6 editions."
      end

      it "logs an ouput for the title changes that would be made" do
        assert_output(/#{log_output}#{dry_run_output}/) { task.invoke("dry_run") }
      end
    end

    describe "running for real" do
      let(:confirmation_output) do
        "Titles were changed from 3 documents to 6 editions."
      end

      it "updates edition titles to their document titles" do
        assert_output(/#{log_output}#{confirmation_output}/) { task.invoke("run_for_real") }
        ContentBlockManager::ContentBlock::Edition.find_each do |edition|
          assert_equal edition.document.title, edition.title
        end
      end
    end

    describe "when title is already set" do
      it "skips editions with titles" do
        edition_with_title = create(:content_block_edition, document: documents.first)
        edition_with_title.update!(title: "set title")
        skipped_output = "Skipping Edition #{edition_with_title.id} because title already set"

        assert_output(/#{skipped_output}/) { task.invoke("run_for_real") }
        assert_equal "set title", edition_with_title.title
      end
    end
  end
end
