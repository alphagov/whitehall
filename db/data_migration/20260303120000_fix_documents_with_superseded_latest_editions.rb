documents_to_fix = Document
  .joins(:latest_edition)
  .where(editions: { state: "superseded" })

puts "Found #{documents_to_fix.count} documents with superseded latest editions"

fixed_with_existing_unpublishing = 0
fixed_by_creating_unpublishing = 0
fixed_by_promoting_edition = 0

documents_to_fix.find_each do |document|
  ActiveRecord::Base.transaction do
    superseded_edition = document.latest_edition

    # Case 1: A deleted edition exists after the superseded edition
    # Change: deleted → unpublished (keep or create PublishedInError unpublishing)
    newer_deleted_edition = Edition
      .unscoped
      .where(document_id: document.id)
      .where("editions.id > ?", superseded_edition.id)
      .where(state: "deleted")
      .order("editions.id": :desc)
      .first

    if newer_deleted_edition
      puts "Document #{document.id} (slug: #{document.slug}): Changing deleted edition #{newer_deleted_edition.id} to unpublished"

      if newer_deleted_edition.unpublishing
        fixed_with_existing_unpublishing += 1
      else
        Unpublishing.create!(
          edition: newer_deleted_edition,
          unpublishing_reason: UnpublishingReason::PublishedInError,
          document_type: newer_deleted_edition.type,
          slug: document.slug,
          unpublished_at: Time.zone.now,
        )
        fixed_by_creating_unpublishing += 1
      end

      newer_deleted_edition.update_column(:state, "unpublished")
      document.update_edition_references
      next
    end

    # Case 2: A newer published edition exists
    # Change: none, just update references to point to the published edition
    published_edition = Edition
      .unscoped
      .where(document_id: document.id)
      .where(state: "published")
      .order("editions.id": :desc)
      .first

    if published_edition && published_edition.id > superseded_edition.id
      puts "Document #{document.id} (slug: #{document.slug}): Promoting newer published edition #{published_edition.id}"
      document.update_edition_references
      fixed_by_promoting_edition += 1
      next
    end

    # Case 3: A newer unpublished edition exists
    # Change: none, just update references to point to the unpublished edition
    unpublished_edition = Edition
      .unscoped
      .where(document_id: document.id)
      .where(state: "unpublished")
      .order("editions.id": :desc)
      .first

    if unpublished_edition && unpublished_edition.id > superseded_edition.id
      puts "Document #{document.id} (slug: #{document.slug}): Promoting newer unpublished edition #{unpublished_edition.id}"
      document.update_edition_references
      fixed_by_promoting_edition += 1
      next
    end

    # Case 4: There is no edition newer than the current superseded edition.
    # (Any published edition found is older.)
    puts "Document #{document.id} (slug: #{document.slug}): Converting superseded edition #{superseded_edition.id} to unpublished"

    if published_edition && published_edition.id < superseded_edition.id
      published_edition.update_column(:state, "superseded")
    end

    unless superseded_edition.unpublishing
      Unpublishing.create!(
        edition: superseded_edition,
        unpublishing_reason: UnpublishingReason::PublishedInError,
        document_type: superseded_edition.type,
        slug: document.slug,
        unpublished_at: Time.zone.now,
      )
    end

    superseded_edition.update_column(:state, "unpublished")
    document.update_edition_references
    fixed_by_creating_unpublishing += 1
  end
end

puts "\nDocuments processed: #{documents_to_fix.count}"
puts "Fixed (with existing unpublishing):         #{fixed_with_existing_unpublishing}"
puts "Fixed (created PublishedInError):           #{fixed_by_creating_unpublishing}"
puts "Fixed (by promoting published/unpublished): #{fixed_by_promoting_edition}"
puts "Total successfully fixed:                   #{fixed_with_existing_unpublishing + fixed_by_creating_unpublishing + fixed_by_promoting_edition}"

puts "\nVerification:"

remaining_count = Document.joins(:latest_edition).where(editions: { state: "superseded" }).count
puts "Remaining documents with superseded latest editions: #{remaining_count}"
