# Enqueue republishing for editions listed in a text file
#
# Summary
# - Reads a list of lines and extracts document IDs.
# - The task deduplicates IDs and (optionally) limits to a TEST_BATCH for safe trials.
# - Enqueueing uses the bulk republishing pattern:
#   `PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", doc_id, true)`
#
# Usage
# - The task accepts a single rake argument for the input file.
# - Examples (dry run is the default):
#     bundle exec rake "data_migration:enqueue_republishing_from_file[further_filtered_documents.txt]"
#     k exec -it deploy/whitehall-admin -- rake 'data_migration:enqueue_republishing_from_file[further_filtered_documents.txt]'

namespace :data_migration do
  desc "Enqueue republishing for editions listed in text/log file"
  task :enqueue_republishing_from_file, [:file] => :environment do |_t, args|
    require "thor"
    shell = Thor::Shell::Basic.new

    args.with_defaults(file: "further_filtered_documents.txt")
    input_file = args[:file].to_s.strip

    dry_run = true

    test_batch_size = nil

    if $stdin.tty?
      shell.say "About to run the republishing enqueue task."
      shell.say "Would you like to apply the updates for real, show a preview of what the changes will be, or cancel?"
      shell.say "  1) Dry run (preview only)"
      shell.say "  2) Apply changes (no preview)"
      shell.say "  3) Cancel"

      response = shell.ask("Enter 1, 2, or 3:")
      case response.to_s.strip
      when "1"
        dry_run = true
      when "2"
        dry_run = false
      else
        shell.say "Cancelled."
        abort
      end

      test_batch_resp = shell.ask("Enter a TEST_BATCH size (0 to disable, blank to leave disabled):")
      test_batch_resp = test_batch_resp.to_s.strip
      if test_batch_resp =~ /^\d+$/
        parsed_batch = test_batch_resp.to_i
        test_batch_size = parsed_batch.positive? ? parsed_batch : nil
      end
    else
      shell.say "Not running interactively; defaulting to dry run with no TEST_BATCH."
    end

    parse_ids = lambda do |path, shell|
      ids = []
      file_path = Rails.root.join(path)
      unless File.exist?(file_path)
        shell.say "File not found: #{file_path}"
        abort
      end

      shell.say "Reading: #{file_path}"
      File.foreach(file_path) do |line|
        text = line.to_s.strip
        next if text.empty?

        if (m = text.match(/ID:\s*(\d{1,10})/i))
          ids << m[1].to_i
        elsif text =~ /^\d+$/
          ids << text.to_i
        end
      end

      ids.compact
    end

    raw_ids = parse_ids.call(input_file, shell)
    total_ids_before_dedup = raw_ids.compact.length

    parsed_ids = raw_ids.compact.uniq

    if parsed_ids.empty?
      shell.say "No document ids found in the provided file."
      abort
    end

    processing_ids = if test_batch_size
                       shell.say "TEST_BATCH active — only processing first #{test_batch_size} ids"
                       parsed_ids.first(test_batch_size)
                     else
                       parsed_ids
                     end

    puts "\n#{dry_run ? '--- DRY RUN - will NOT enqueue any jobs ---' : '--- ENQUEUE START ---'}"
    puts "Found #{parsed_ids.length} unique document ids in file (#{total_ids_before_dedup} before dedup)."
    puts "Processing #{processing_ids.length} ids."

    enqueued_count = 0

    processing_ids.each do |document_id|
      if dry_run
        puts "Would enqueue republishing for document_id=#{document_id}"
      else
        begin
          PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
          puts "Enqueued bulk republishing for document_id=#{document_id}"
          enqueued_count += 1
        rescue StandardError => e
          raise "Failed to enqueue #{document_id}: #{e.message}"
        end
      end
    end

    if dry_run
      puts "--- End DRY RUN ---\n"
    else
      puts "\nSummary: Enqueued=#{enqueued_count}"
    end
  end
end
