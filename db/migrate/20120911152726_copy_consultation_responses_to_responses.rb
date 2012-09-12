class CopyConsultationResponsesToResponses < ActiveRecord::Migration
  def up
    documents = ConsultationResponse.all.map(&:consultation_document).uniq

    documents.each do |document|
      # Get the published or, failing that, the latest Consultation Response
      consultation_response = document.published_consultation_response ||
                              document.consultation_responses.order('created_at DESC').first

      # Let's add the response to the published, and if it's not the same, the latest edition of the consultation
      [document.published_edition, document.latest_edition].compact.uniq.each do |consultation|
        if consultation.response.present?
          puts "Skipping response creation for consultation with id #{consultation.id} as it already has a response."
        else
          puts "Creating response for consultation with id #{consultation.id}"
          response_attributes = consultation_response.attributes.slice('summary', 'created_at', 'updated_at')
          response = consultation.create_response!(response_attributes)

          # Copy each of the attachments from the Consultation Response to the new Response
          number_of_attachments = consultation_response.attachments.length
          consultation_response.attachments.each do |attachment|
            response.attachments << attachment
          end

          response.reload
          if number_of_attachments == response.attachments.length
            puts "Added #{number_of_attachments} attachments to the response to consultation #{consultation.id}"
          else
            puts "Something is amiss.  I expected #{number_of_attachments} attachments to be added but there are only #{response.attachments.length} on the response"
          end
        end
      end
    end
  end

  def down
    # Intentionally blank as I don't think it's worth the effort to turn Responses back into Consultation Responses
  end

  class Document < ActiveRecord::Base
    has_one  :published_edition,
             class_name: 'Edition',
             conditions: { state: 'published' }
    has_one  :latest_edition,
             class_name: 'Edition',
             conditions: %{
               NOT EXISTS (
                 SELECT 1 FROM editions e2
                 WHERE e2.document_id = editions.document_id
                 AND e2.id > editions.id
                 AND e2.state <> 'deleted')}
    has_many :consultation_responses,
             class_name: 'ConsultationResponse',
             foreign_key: :consultation_document_id,
             dependent: :destroy
    has_one  :published_consultation_response,
             class_name: 'ConsultationResponse',
             foreign_key: :consultation_document_id,
             conditions: { state: 'published' }
  end

  class Edition < ActiveRecord::Base
    self.store_full_sti_class = false # Without this, AR will look for a type of <MigrationClassName>::Edition
  end

  class EditionAttachment < ActiveRecord::Base
    belongs_to :attachment
    belongs_to :edition
  end

  class ConsultationResponse < Edition
    belongs_to :consultation_document, foreign_key: :consultation_document_id, class_name: 'Document'
    has_many :edition_attachments, foreign_key: "edition_id"
    has_many :attachments, through: :edition_attachments
  end

  class Consultation < Edition
    has_one :response, foreign_key: :edition_id
  end

  class ConsultationResponseAttachment < ActiveRecord::Base
    belongs_to :response
    belongs_to :attachment
  end

  class Response < ActiveRecord::Base
    has_many :consultation_response_attachments
    has_many :attachments, through: :consultation_response_attachments
  end

  class Attachment < ActiveRecord::Base
  end
end