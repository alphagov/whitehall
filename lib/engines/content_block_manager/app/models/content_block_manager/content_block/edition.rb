module ContentBlockManager
  module ContentBlock
    class Edition < ApplicationRecord
      validates :title, presence: true
      validates :change_note, presence: true, if: :major_change?, on: :change_note
      validates :major_change, inclusion: [true, false], on: :change_note

      include Documentable
      include HasAuditTrail
      include HasAuthors
      include ValidatesDetails
      include HasLeadOrganisation
      include Workflow
      include Diffable

      scope :current_versions, lambda {
        joins(
          "LEFT JOIN content_block_documents document ON document.latest_edition_id = content_block_editions.id",
        ).where(state: "published")
      }

      def update_document_reference_to_latest_edition!
        document.update!(latest_edition_id: id)
      end

      def render(embed_code)
        ContentBlockTools::ContentBlock.new(
          document_type: "content_block_#{block_type}",
          content_id: document.content_id,
          title:,
          details:,
          embed_code:,
        ).render
      end

      def first_class_details
        details.select { |_k, v| v.is_a?(String) }
      end

      def clone_edition(creator:)
        new_edition = dup
        new_edition.state = "draft"
        new_edition.organisation = lead_organisation
        new_edition.creator = creator

        new_edition
      end

      def add_object_to_details(object_type, body)
        key = key_for_object(body)

        details[object_type] ||= {}
        details[object_type][key] = body.to_h
      end

      def update_object_with_details(object_type, object_name, body)
        key = key_for_object(body)

        if key != object_name
          details[object_type].delete(object_name)
        end

        add_object_to_details(object_type, body)
      end

      def key_for_object(object)
        object["name"]&.parameterize.presence || SecureRandom.alphanumeric.downcase
      end
    end
  end
end
