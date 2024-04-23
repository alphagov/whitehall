module EmailOveride
  class EmailOverride
    def initialize(document_collection_id:, taxon_content_id:, dry_run: true)
      @document_collection_id = document_collection_id
      @taxon_content_id = taxon_content_id
      @dry_run = dry_run
    end

    def call
      find_valid_document_collection
      find_taxon_content_item

      unless @dry_run
        @document_collection.update!(taxonomy_topic_email_override: @taxon_content_id)
      end

      puts "The document collection: '#{@document_collection.title}' will now have a sign up link to '#{@taxon_name}' when published"
    end

  private

    def find_valid_document_collection
      @document_collection = DocumentCollection.find_by(id: @document_collection_id)
      raise "Cannot find document collection with ID: #{@document_collection_id}." unless @document_collection

      # Only allow email overrides to be set on unpublished documents
      raise "This document has been published previously. Email overrides can only be changed when the document has no been previously published" if @document_collection.document.live_edition_id.present?
    end

    def find_taxon_content_item
      @taxon_content_item = Services.publishing_api.get_content(@taxon_content_id).to_h
      raise "Cannot find a taxon with the content ID #{@taxon_content_id}" unless @taxon_content_item

      @taxon_name = @taxon_content_item.fetch("title")
    end
  end
end
