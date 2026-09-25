# One-off investigation script (not a permanent task) to find assets that
# Asset Manager still has marked deleted, but that Whitehall's *current*
# view of the document does not.
#
# Background: this was originally written on the theory that a specific
# Whitehall bug (fixed by commits 5131ca537c, 57be018bdf and 09d50572c3)
# fully explained these mismatches - see commit 8f64bd7972 ("Restore
# stale-deleted assets when syncing attachment metadata") for that writeup.
# That bug could only ever fire while a document was unpublished, so this
# script originally only checked documents with an Unpublishing history.
#
# On investigating a real example (document_id 308650), that theory turned
# out not to fit the timeline: the mismatch predated the document ever being
# unpublished. The root cause for that particular document remains
# unconfirmed (current leading guess: a manual/support-side Asset Manager
# API call, not a Whitehall application bug). Since we can no longer be
# confident the mismatch is confined to previously-unpublished documents,
# this script now checks *every* document, not just ones with an
# Unpublishing history.
#
# Only checks Attachment/AttachmentData - not Image/ImageData. Images only
# gained draft support in summer 2026; before that they were always live,
# so they were never subject to this kind of mismatch and can be ignored.
#
# Only Attachment rows whose attachable_type is "Edition" are considered -
# attachments on nested attachables (e.g. a Consultation's outcome or
# response form) share the same underlying mechanism and risk, but aren't
# covered by this pass.
#
# What counts as "Whitehall's current view", and why it's not a single
# obvious method call - two things were tried and rejected, both confirmed
# by reproducing the false positive directly against a real DB rather than
# just reading the code:
#
#   1. AttachmentData#deleted? resolves via significant_attachment, which
#      tries last_publicly_visible_attachment first - the most recent
#      attachment whose *edition* is publicly visible (published or
#      withdrawn), regardless of that attachment's own deleted flag. A
#      document with an older withdrawn edition (still publicly visible)
#      and a newer, actually-latest edition that's unpublished with its
#      attachment genuinely deleted: this finds the older withdrawn
#      edition's still-live attachment and stops there, never even looking
#      at the latest one. False negative for our purposes (wrongly treats a
#      real deletion as live).
#
#   2. Looking up "the most recent Attachment row that exists for this
#      attachment_data, and checking its own deleted flag" is closer, but
#      still wrong: if the current/latest edition simply doesn't carry the
#      attachment forward at all (no row for it there - e.g. a new draft
#      was made without that file rather than the file being explicitly
#      deleted from an existing one), this falls back to an older edition's
#      untouched, deleted: false row and wrongly treats that as still live
#      too.
#
# What we actually want: does the document's *true* current/latest edition
# have a non-deleted Attachment row for this specific attachment_data? If
# not - whether because there's a deleted row there, or no row there at
# all - Whitehall doesn't consider it part of the current document, and
# that's a legitimate reason for Asset Manager to say the asset is gone.
# "True current/latest edition" here means Document#latest_edition_id, the
# same column Whitehall itself maintains (via Document#update_edition_
# references) and relies on elsewhere - not just the highest edition id,
# since that association excludes editions in "deleted" state and so can
# differ from a naive MAX(id).
#
# How the check works: rather than calling Asset Manager's authenticated API
# (which needs Services.asset_manager configured with working credentials
# wherever you run this), this makes a plain, unauthenticated HTTP HEAD
# request to each asset's public URL instead. That's a reliable signal on
# its own: in both MediaController and WhitehallMediaController, the
# `asset` accessor raises MediaErrors::AssetDeleted (-> 410 Gone) as the
# very first thing #download does, before the replacement/draft-host/
# authorization/filename checks ever run - so a 410 unambiguously means
# deleted_at is set, and nothing else does. This also means the script
# needs no Whitehall-side Asset Manager credentials at all - just plain
# internet access to whichever host you point it at.
#
# Points at the real, public GOV.UK asset host by default, since the
# whole point is checking the live service. Override with the ASSETS_HOST
# env var if you need to (e.g. an integration/staging host).
#
# This is a live production service, so this deliberately does one request
# at a time with a small delay between them (REQUEST_DELAY env var,
# seconds, default 0.1) rather than hammering it - expect this to take a
# while for a large candidate set.
#
# Usage:
#   bin/rails runner script/find_wrongly_deleted_assets.rb [output_csv_path]
#   ASSETS_HOST=https://assets.example.com bin/rails runner script/find_wrongly_deleted_assets.rb
#
# Output: a CSV with one row per asset that 410s on the public site but
# isn't deleted from Whitehall's point of view, with enough to both
# sanity-check the finding (open url in a browser, confirm it 410s) and
# drive a restore:
#   asset_manager_id,filename,asset_variant,attachment_data_id,document_id,url

require "csv"
require "net/http"

ASSETS_HOST = ENV.fetch("ASSETS_HOST", "https://assets.publishing.service.gov.uk")
REQUEST_DELAY = Float(ENV.fetch("REQUEST_DELAY", "0.1"))

output_path = ARGV[0] || Rails.root.join("tmp", "wrongly_deleted_assets_#{Time.zone.now.to_i}.csv")

def asset_url(asset)
  URI.join(ASSETS_HOST, Addressable::URI.encode("media/#{asset.asset_manager_id}/#{asset.filename}"))
end

def asset_gone?(uri)
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 10) do |http|
    http.head(uri.request_uri)
  end
  response.code == "410"
end

puts "Loading edition -> document mapping..."
edition_to_document = Edition.unscoped.pluck(:id, :document_id).to_h

puts "Loading each document's canonical latest edition..."
latest_edition_id_by_document = Document.pluck(:id, :latest_edition_id).to_h

puts "Loading attachment_data candidates..."
attachment_pairs = Attachment
  .where(attachable_type: "Edition")
  .pluck(:attachment_data_id, :attachable_id)

# A handful of Attachment rows have a nil or otherwise unmatched
# attachable_id (bad historical data, or an edition that's since been hard
# deleted) - skip those rather than blowing up on a missing hash key.
data_id_to_document_id = attachment_pairs.each_with_object({}) do |(data_id, edition_id), memo|
  document_id = edition_to_document[edition_id]

  if document_id.nil?
    warn "Skipping attachment_data #{data_id}: no matching edition for attachable_id #{edition_id.inspect}"
    next
  end

  memo[data_id] = document_id
end
total_candidates = data_id_to_document_id.size
puts "Found #{total_candidates} candidate attachment_data records to check against #{ASSETS_HOST}."

# Is there a non-deleted Attachment row for this attachment_data on the
# document's true current/latest edition, whether or not that's the same
# edition the row we found `data_id` via above belongs to?
def live_on_latest_edition?(data_id, latest_edition_id)
  return false if latest_edition_id.nil?

  Attachment.exists?(attachable_type: "Edition", attachable_id: latest_edition_id, attachment_data_id: data_id, deleted: false)
end

checked = 0
found = 0
errors = 0

CSV.open(output_path, "w") do |csv|
  csv << %w[asset_manager_id filename asset_variant attachment_data_id document_id url]

  data_id_to_document_id.each do |data_id, document_id|
    checked += 1
    print "\rChecked #{checked}/#{total_candidates}, found #{found} wrongly-deleted assets, #{errors} errors..." if (checked % 10).zero?

    # Not part of the document's current edition (deleted there, or never
    # carried forward to it) - a legitimate reason for Asset Manager to say
    # it's gone, not our target here.
    next unless live_on_latest_edition?(data_id, latest_edition_id_by_document[document_id])

    attachment_data = AttachmentData.find_by(id: data_id)

    if attachment_data.nil?
      warn "\nSkipping attachment_data #{data_id}: record no longer exists"
      next
    end

    attachment_data.assets.each do |asset|
      begin
        url = asset_url(asset)
        gone = asset_gone?(url)
      rescue StandardError => e
        errors += 1
        warn "\nError checking asset #{asset.asset_manager_id} (AttachmentData #{data_id}): #{e.message}"
        next
      ensure
        sleep REQUEST_DELAY
      end

      next unless gone

      found += 1
      csv << [asset.asset_manager_id, asset.filename, asset.variant, data_id, document_id, url.to_s]
      csv.flush
    end
  end
end

puts "\nDone. Checked #{checked} attachment_data records, found #{found} wrongly-deleted assets, #{errors} errors."
puts "Output written to #{output_path}"
