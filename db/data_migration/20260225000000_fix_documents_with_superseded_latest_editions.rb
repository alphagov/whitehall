documents_to_fix = Document
  .joins(:latest_edition)
  .where(editions: { state: "superseded" })

puts "Found #{documents_to_fix.count} documents with superseded latest editions"

fixed_count = 0
skipped_count = 0

documents_to_fix.find_each do |document|
  ActiveRecord::Base.transaction do
    superseded_edition = document.latest_edition

    deleted_edition_with_unpublishing = Edition
      .unscoped
      .where(document_id: document.id)
      .where("editions.id > ?", superseded_edition.id)
      .where(state: "deleted")
      .joins(:unpublishing)
      .order("editions.id": :asc)
      .first

    if deleted_edition_with_unpublishing
      puts "Document #{document.id} (slug: #{document.slug}): Changing edition #{deleted_edition_with_unpublishing.id} from deleted to unpublished"

      deleted_edition_with_unpublishing.update_column(:state, "unpublished")

      document.update_edition_references

      fixed_count += 1
    else
      puts "Document #{document.id} (slug: #{document.slug}): No deleted edition with unpublishing found - skipping"
      skipped_count += 1
    end
  end
end

puts "Migration complete: #{fixed_count} documents fixed, #{skipped_count} documents skipped"
