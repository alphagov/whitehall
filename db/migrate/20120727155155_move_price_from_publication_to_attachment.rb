class MovePriceFromPublicationToAttachment < ActiveRecord::Migration
  def up
    add_column :attachments, :price_in_pence, :integer

    Document.where(document_type: 'Publication').each do |publication|
      # Get the published edition of this publication
      published_edition = publication.published_edition

      # Only proceed if there's a published edition with a price
      if published_edition && published_edition.price_in_pence.present?

        # If we don't have an attachment to copy the price to then print the edition ID and
        # price so that we don't lose potentially useful data when we remove the price
        # from the editions table.
        if published_edition.attachments.empty?
          puts "*NOTE* Edition #{published_edition.id} has a price (#{published_edition.price_in_pence}) but no attachments to copy it to."
        else

          # If there's more than one attachment then print the edition ID as we'll need to check whether we've copied
          # the price to the correct attachment
          if published_edition.attachments.length > 1
            puts "*NOTE* Edition #{published_edition.id} has multiple attachments.  Manually check that we've copied the price to the correct one."
          end

          first_attachment = published_edition.attachments.order(:created_at).first

          # Fail fast if we're trying to overwrite an existing price with something different
          if first_attachment.price_in_pence.present? && first_attachment.price_in_pence != published_edition.price_in_pence
            raise "The Price on the attachment is different from the one on the publication.  Aborting."
          else
            first_attachment.update_column(:price_in_pence, published_edition.price_in_pence)
          end
        end
      end
    end

    remove_column :editions, :price_in_pence
  end

  def down
    add_column :editions, :price_in_pence, :integer
    remove_column :attachments, :price_in_pence
  end
end
