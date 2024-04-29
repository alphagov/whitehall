require "test_helper"
require "rake"

class SetTaxonomyTopicEmailOverrideRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#set_taxonomy_topic_email_override" do
    let(:task) { Rake::Task["set_taxonomy_topic_email_override"] }

    it "raises an error unless document collection ID and taxon content ID are both provided" do
      e = assert_raises(StandardError) { task.invoke }
      assert_equal e.message, "Document collection ID and taxon content ID are required arguments"
    end

    it "raises an error if document collection does not exist" do
      e = assert_raises(StandardError) { task.invoke("nothing-at-this-id", "taxon-content-id") }
      assert_equal e.message, "Cannot find document collection with ID: nothing-at-this-id"
    end

    it "raises an error if document collection has previously been published" do
      document_collection = create(:document_collection, :published)
      e = assert_raises(StandardError) { task.invoke(document_collection.id.to_s, "taxon-content-id") }
      assert_equal e.message, "Cannot set a taxonomy topic email override on previously published documents"
    end

    it "raises an error if no content item is returned for the given taxon content ID" do
      document_collection = create(:document_collection, :draft)
      bad_taxon_content_id = "123abc"
      stub_publishing_api_does_not_have_item(bad_taxon_content_id)
      assert_raises(GdsApi::HTTPNotFound) do
        task.invoke(document_collection.id.to_s, bad_taxon_content_id.to_s)
      end
    end

    describe "default dry run feature" do
      let(:document_collection) { create(:document_collection, :draft) }
      let(:taxon_content_id) { "123abc" }
      let(:taxon_title) { "Taxonomy topic" }
      let(:dry_run_output) do
        "This was a dry run. Taxonomy topic email override would have been set to #{taxon_title} for document collection #{document_collection.id}, #{document_collection.title}."
      end
      let(:confirmation_output) do
        "Taxonomy topic email override set to #{taxon_title} for document collection #{document_collection.id}, #{document_collection.title}."
      end

      before do
        stub_publishing_api_has_item(content_id: taxon_content_id, title: taxon_title)
      end

      context "when no confirmation_string argument is provided" do
        it "it defaults to running as dry run and does not update the document collection" do
          assert_output(/#{dry_run_output}/) { task.invoke(document_collection.id.to_s, taxon_content_id.to_s) }
          assert document_collection.taxonomy_topic_email_override.nil?
        end
      end

      context "when anything other than run_for_real is provided" do
        it "it defaults to running as dry run and does not update the document collection" do
          assert_output(/#{dry_run_output}/) { task.invoke(document_collection.id.to_s, taxon_content_id.to_s, "dry_runnish") }
          assert document_collection.taxonomy_topic_email_override.nil?
        end
      end

      context "run_for_real is provided" do
        it "updates the taxonomy topic email override field of a document collection" do
          assert_output(/#{confirmation_output}/) { task.invoke(document_collection.id.to_s, taxon_content_id.to_s, "run_for_real") }
          assert_equal DocumentCollection.find(document_collection.id).taxonomy_topic_email_override, taxon_content_id
        end
      end
    end
  end
end
