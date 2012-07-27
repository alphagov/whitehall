class CopyIsbnFromPublicationToAttachment < ActiveRecord::Migration
  def up
    Document.where(document_type: 'Publication').each do |publication|
      # Get the published edition of this publication
      published_edition = publication.published_edition

      # Only proceed if there's a published edition with an ISBN
      if published_edition && published_edition.isbn.present?

        # If we don't have an attachment to copy the ISBN to then print the edition ID and
        # ISBN so that we don't lose potentially useful data when we remove the ISBN
        # from the editions table.
        if published_edition.attachments.empty?
          puts "*NOTE* Edition #{published_edition.id} has an ISBN (#{published_edition.isbn}) but no attachments to copy it to."
        else

          # If there's more than one attachment then print the edition ID as we'll need to check whether we've copied
          # the ISBN to the correct attachment
          if published_edition.attachments.length > 1
            puts "*NOTE* Edition #{published_edition.id} has multiple attachments.  Manually check that we've copied the ISBN to the correct one."
          end

          first_attachment = published_edition.attachments.order(:created_at).first

          # Fail fast if we're trying to overwrite an existing ISBN with something different
          if first_attachment.isbn.present? && first_attachment.isbn != published_edition.isbn
            raise "The ISBN on the attachment is different from the one on the publication.  Aborting."
          else
            first_attachment.update_attribute(:isbn, published_edition.isbn)
          end
        end
      end
    end
  end

  def down
    # Intentionally blank
  end
end
