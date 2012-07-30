class CopyOrderUrlsFromPublicationsToAttachments < ActiveRecord::Migration
  def up
    connection = ActiveRecord::Base.connection

    connection.select_values("SELECT id FROM documents WHERE document_type = 'Publication'").each do |document_id|

      # Get the ID and Order URL of the published edition
      connection.select_rows("SELECT id, order_url FROM editions WHERE document_id = #{document_id} AND state = 'published'").each do |(edition_id, edition_order_url)|

        # Only proceed if there's a published edition with an Order URL
        if edition_id && edition_order_url.present?

          attachments = connection.select_rows("SELECT attachments.id, attachments.order_url FROM attachments
            INNER JOIN edition_attachments ON attachments.id = edition_attachments.attachment_id
            INNER JOIN editions ON editions.id = edition_attachments.edition_id
            WHERE editions.id = #{edition_id}
            ORDER BY attachments.created_at ASC")

          # If we don't have an attachment to copy the Order URL to then print the edition ID and
          # Order URL so that we don't lose potentially useful data when we remove the Order URL
          # from the editions table.
          if attachments.length == 0
            puts "*NOTE* Edition #{edition_id} has an Order URL (#{edition_order_url}) but no attachments to copy it to."
          else

            # If there's more than one attachment then print the edition ID as we'll need to check whether we've copied
            # the Order URL to the correct attachment
            if attachments.length > 1
              puts "*NOTE* Edition #{edition_id} has multiple attachments.  Manually check that we've copied the Order URL to the correct one."
            end

            attachment_id, attachment_order_url = attachments.first

            # Fail fast if we're trying to overwrite an existing Order URL with something different
            if attachment_order_url.present? && attachment_order_url != edition_order_url
              raise "The Order URL on the attachment is different from the one on the publication.  Aborting."
            else
              connection.update("UPDATE attachments SET order_url = '#{edition_order_url}' WHERE id = #{attachment_id}")
              puts "*INFO* Set Order URL to '#{edition_order_url}' for attachment #{attachment_id} and edition #{edition_id}"
            end

          end
        end

      end
    end
  end

  def down
    # Intentionally blank
  end
end
