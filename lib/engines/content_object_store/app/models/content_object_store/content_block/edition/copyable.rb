module ContentObjectStore
  module ContentBlock::Edition::Copyable
    extend ActiveSupport::Concern

    def create_copy(edition_params:)
      new_edition = dup.tap do |edition|
        edition.state = :draft
        edition.creator = creator
        edition.document = document
        edition.assign_attributes(
          filter_params_for_validation_check(edition_params),
        )
      end

      unless new_edition.valid?
        raise ActiveRecord::RecordInvalid, new_edition
      end

      new_edition.save!
      new_edition.update_document_reference_to_latest_edition!
      new_edition
    end

    def filter_params_for_validation_check(edition_params)
      # Remove the `creator` as this is not modifiable and will return a false negative
      validation_params = edition_params.except(:creator)

      # Remove document `block_type` as this is not modifiable
      # Add the original Document ID to avoid `valid?` creating a new Document
      if validation_params.key?(:document_attributes)
        validation_params[:document_attributes] = validation_params[:document_attributes]
                                                    .except(:block_type)
                                                    .merge(id: document.id)
      end

      validation_params
    end
  end
end
