require 'csv'

puts ['Title', 'Latest edition ID', 'Old delivered on', 'New delivered on', 'Old first published at', 'New first published at', 'Error'].to_csv
CSV.foreach(Rails.root.join('db/data_migration/20121012135700_upload_dft_speeches.csv'), headers: true) do |row|
  # We weren't creating Document Sources when we first imported DFT Speeches so we have to lookup using title
  title = row['title']

  # I'm explicitly setting delivered_on as a date (to avoid the problem we encountered last time round)
  # and setting the first_published_at to 13:00 on the same day, to avoid any ambiguity around midnight
  # in BST (midnight BST is 23:00 the day before in UTC).
  day, month, year   = row['first published'].split "/"
  delivered_on       = Date.parse("#{year}-#{month}-#{day}")
  first_published_at = Time.zone.parse("#{year}-#{month}-#{day} 13:00:00")

  latest_edition_id, error                       = nil, nil
  old_delivered_on, new_delivered_on             = nil, nil
  old_first_published_at, new_first_published_at = nil, nil

  if delivered_on
    # I think it makes sense to update editions even if they've been deleted
    if editions = Edition.unscoped.find_all_by_title(title)

      # Find the unique documents for the editions matching our title
      documents = editions.map(&:document).uniq

      # Only consider the documents that don't have an associated document source, as we know that importing these
      # speeches didn't create document sources
      documents_without_sources = documents.reject { |d| d.document_source.present? }

      # Find the latest edition for the first document that doesn't have a source.
      latest_editions = documents_without_sources.map(&:latest_edition).compact
      if latest_editions.any?
        latest_edition = latest_editions.first
        latest_edition_id = latest_edition.id

        old_delivered_on                  = latest_edition.delivered_on
        old_first_published_at            = latest_edition.first_published_at
        latest_edition.delivered_on       = delivered_on
        latest_edition.first_published_at = first_published_at
        new_delivered_on                  = latest_edition.delivered_on
        new_first_published_at            = latest_edition.first_published_at

        unless latest_edition.save(validate: false)
          error = "Couldn't update edition"
        end
      else
        error = "Couldn't find any latest editions"
      end
    else
      error = "Edition not found"
    end
  else
    error = "Missing date from the CSV file"
  end

  puts [title, latest_edition_id, old_delivered_on, new_delivered_on, old_first_published_at, new_first_published_at, error].to_csv
end