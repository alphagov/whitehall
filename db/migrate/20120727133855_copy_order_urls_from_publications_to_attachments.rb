class CopyOrderUrlsFromPublicationsToAttachments < ActiveRecord::Migration
  def up
    Document.where(document_type: 'Publication').each do |publication|
      # Get the published edition of this publication
      published_edition = publication.published_edition

      # Only proceed if there's a published edition with an order url
      if published_edition && published_edition.order_url.present?

        # If we don't have an attachment to copy the order url to then print the edition ID and
        # order url so that we don't lose potentially useful data when we remove the order url
        # from the editions table.
        if published_edition.attachments.empty?
          puts "*NOTE* Edition #{published_edition.id} has an order url (#{published_edition.order_url}) but no attachments to copy it to."
        else

          # If there's more than one attachment then print the edition ID as we'll need to check whether we've copied
          # the order url to the correct attachment
          if published_edition.attachments.length > 1
            puts "*NOTE* Edition #{published_edition.id} has multiple attachments.  Manually check that we've copied the order url to the correct one."
          end

          first_attachment = published_edition.attachments.order(:created_at).first

          # Fail fast if we're trying to overwrite an existing order url with something different
          if first_attachment.order_url.present? && first_attachment.order_url != published_edition.order_url
            raise "The Order URL on the attachment is different from the one on the publication.  Aborting."
          else
            first_attachment.update_attribute(:order_url, published_edition.order_url)
          end
        end
      end
    end
  end

  def down
    # Intentionally blank
  end
end
