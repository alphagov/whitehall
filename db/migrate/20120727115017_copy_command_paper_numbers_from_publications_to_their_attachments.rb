class CopyCommandPaperNumbersFromPublicationsToTheirAttachments < ActiveRecord::Migration
  def up
    Document.where(document_type: 'Publication').each do |publication|
      # Get the published edition of this publication
      published_edition = publication.published_edition

      # Only proceed if there's a published edition with a command paper number
      if published_edition && published_edition.command_paper_number.present?

        # If we don't have an attachment to copy the command paper number to then print the edition ID and
        # command paper number so that we don't lose potentially useful data when we remove the command paper
        # number from the editions table.
        if published_edition.attachments.empty?
          puts "*NOTE* Edition #{published_edition.id} has a command paper number (#{published_edition.command_paper_number}) but no attachments to copy it to."
        else

          # If there's more than one attachment then print the edition ID as we'll need to check whether we've copied
          # the command paper number to the correct attachment
          if published_edition.attachments.length > 1
            puts "*NOTE* Edition #{published_edition.id} has multiple attachments.  Manually check that we've copied the command paper number to the correct one."
          end

          first_attachment = published_edition.attachments.order(:created_at).first

          # Fail fast if we're trying to overwrite an existing command paper number with something different
          if first_attachment.command_paper_number.present? && first_attachment.command_paper_number != published_edition.command_paper_number
            raise "The Command Paper number on the attachment is different from the one on the publication.  Aborting."
          else
            first_attachment.update_column(:command_paper_number, published_edition.command_paper_number)
          end
        end
      end
    end
  end

  def down
    # Intentionally blank
  end
end
