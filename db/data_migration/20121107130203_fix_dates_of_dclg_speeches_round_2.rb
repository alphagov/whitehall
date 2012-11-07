require 'csv'

puts ['Url', 'Latest edition ID', 'Old delivered on', 'New delivered on', 'Old first published at', 'New first published at', 'Error'].to_csv
CSV.foreach(Rails.root.join('db/data_migration/20121031105330_upload_dclg_speeches.csv'), headers: true) do |row|
  source_url = row['old_url']

  # I'm explicitly setting delivered_on as a date (to avoid the problem we encountered last time round)
  # and setting the first_published_at to 13:00 on the same day, to avoid any ambiguity around midnight
  # in BST (midnight BST is 23:00 the day before in UTC).
  first_published_at = row['first_published']
  delivered_on       = row['delivered_on']

  # We only had delivered_on or first_published columns
  if delivered_on.present?
    delivered_on       = Date.parse(delivered_on)
    first_published_at = Time.zone.parse("#{delivered_on} 13:00:00")
  else
    delivered_on       = Date.parse(first_published_at)
    first_published_at = Time.zone.parse("#{first_published_at} 13:00:00")
  end

  latest_edition_id, error                       = nil, nil
  old_delivered_on, new_delivered_on             = nil, nil
  old_first_published_at, new_first_published_at = nil, nil

  if document_series = DocumentSource.find_by_url(source_url)
    if document_series.document
      if latest_edition = document_series.document.latest_edition
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
        error = 'Edition not found'
      end
    else
      error = 'Document not found'
    end
  else
    error = 'Document source not found'
  end

  puts [source_url, latest_edition_id, old_delivered_on, new_delivered_on, old_first_published_at, new_first_published_at, error].to_csv
end