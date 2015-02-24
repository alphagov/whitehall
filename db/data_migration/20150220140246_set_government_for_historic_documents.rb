# We only to update content that has been published, having some kind of publish
# date, and that is not irrecoverably unpublished (eg, not deleted or superseded)
updatable_edition_states = Edition::PUBLICLY_VISIBLE_STATES

Document.where(government_id: nil).find_each do | document |
  edition = Edition.where(document_id: document.id, state: updatable_edition_states)
            .order(created_at: :desc).first

  # Some document won't have any editions in `updatable_edition_states`
  unless edition
    puts "Skipping '#{document.id}', no edition"
    next
  end

  # Most documents have `first_public_at`, which maps to `first_published_at`
  # but some `Speech` rows are missing it, so use `delivered_on` instead
  unless publication_date = edition.first_public_at || edition.delivered_on
    puts "Skipping '#{document.id}' (#{edition.state.upcase}), missing publication date"
    next
  end

  government = Government.on_date(publication_date)
  puts "Setting '#{document.id}' to '#{government.slug}'"

  document.update_attribute(:government, government)

end
