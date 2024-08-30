module ContentObjectStore
  module Publishable
    class PublishingFailureError < StandardError; end

    def publish_with_rollback(schema:, title:, details:)
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield
        content_id = content_block_edition.document.content_id
        organisation_id = content_block_edition.lead_organisation.content_id

        create_publishing_api_edition(
          content_id:,
          schema_id: schema.id,
          title:,
          details: details.to_h,
          links: {
            primary_publishing_organisation: [
              organisation_id,
            ],
          },
        )
        publish_publishing_api_edition(content_id:)
        update_content_block_document_with_live_edition(content_block_edition)
        update_content_block_document_with_latest_edition(content_block_edition)
        content_block_edition.public_send(:publish!)
      rescue PublishingFailureError => e
        discard_publishing_api_edition(content_id:)
        raise e
      end
    end

    def schedule_with_rollback
      raise ArgumentError, "Local database changes not given" unless block_given?

      ActiveRecord::Base.transaction do
        content_block_edition = yield

        update_content_block_document_with_latest_edition(content_block_edition)
        content_block_edition.schedule!
        ContentObjectStore::SchedulePublishingWorker.queue(content_block_edition)
      end
    end

    def update_content_block_document(new_content_block_edition:, update_document_params:)
      # Updates to a Document should never change its block type
      update_document_params.delete(:block_type)

      new_content_block_edition.document.update!(update_document_params)
    end

    def create_new_content_block_edition_for_document(edition_params:)
      @original_content_block_edition.assign_attributes(
        filter_params_for_validation_check(edition_params),
      )

      unless @original_content_block_edition.valid?
        raise ActiveRecord::RecordInvalid, @original_content_block_edition
      end

      new_content_block_edition = ContentObjectStore::ContentBlock::Edition.new(edition_params)
      new_content_block_edition.document_id = @original_content_block_edition.document.id
      new_content_block_edition.save!
      new_content_block_edition
    end

    def filter_params_for_validation_check(edition_params)
      # Remove the `creator` as this is not modifiable and will return a false negative
      validation_params = edition_params.except(:creator)

      # Remove document `block_type`` as this is not modifiable
      # Add the original Document ID to avoid `valid?` creating a new Document
      if validation_params.key?(:document_attributes)
        validation_params[:document_attributes] = validation_params[:document_attributes]
                                                    .except(:block_type)
                                                    .merge(id: @original_content_block_edition.document.id)
      end

      validation_params
    end

  private

    def create_publishing_api_edition(content_id:, schema_id:, title:, details:, links:)
      Services.publishing_api.put_content(content_id, {
        schema_name: schema_id,
        document_type: schema_id,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        title:,
        details:,
        links:,
      })
    end

    def publish_publishing_api_edition(content_id:)
      Services.publishing_api.publish(content_id, "major")
    rescue GdsApi::HTTPErrorResponse => e
      raise PublishingFailureError, "Could not publish #{content_id} because: #{e.message}"
    end

    def discard_publishing_api_edition(content_id:)
      Services.publishing_api.discard_draft(content_id)
    end

    def update_content_block_document_with_latest_edition(content_block_edition)
      content_block_edition.document.update!(
        latest_edition_id: content_block_edition.id,
      )
    end

    def update_content_block_document_with_live_edition(content_block_edition)
      content_block_edition.document.update!(live_edition_id: content_block_edition.id)
    end
  end
end
