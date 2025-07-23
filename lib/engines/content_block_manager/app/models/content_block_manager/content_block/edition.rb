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
      rescue TypeError
        # TODO: Remove this when we've updated Content Block Tools to support an array of telephones
        nil
      end

      def clone_edition(creator:)
        new_edition = dup
        new_edition.assign_attributes(
          state: "draft",
          organisation: lead_organisation,
          creator: creator,
          change_note: nil,
          internal_change_note: nil,
        )
        new_edition
      end

      def add_object_to_details(object_type, body)
        key = key_for_object(object_type, body["title"])

        details[object_type] ||= {}
        details[object_type][key] = remove_destroyed body.to_h
      end

      def update_object_with_details(object_type, object_title, body)
        details[object_type][object_title] = remove_destroyed body.to_h
      end

      def key_for_object(object_type, title)
        base_key = (title.presence || object_type).parameterize
        key = base_key
        counter = 1

        while details.dig(object_type, key).present?
          key = "#{base_key}-#{counter}"
          counter += 1
        end

        key
      end

      def has_entries_for_subschema_id?(subschema_id)
        details[subschema_id].present?
      end

    private

      def remove_destroyed(item)
        item.transform_values { |value|
          case value
          when Hash
            remove_destroyed(value)
          when Array
            value.select { |i| !i.is_a?(Hash) || i.delete("_destroy") != "1" }
          else
            value
          end
        }.to_h
      end
    end
  end
end
