namespace :migrate_calls_for_evidence do
  # Path to the cfe-consultations CSV file
  # Export it from here:
  # https://docs.google.com/spreadsheets/d/1kG2iynakZHm7Js8coDuoXepJe9mfHH0v97gfCDrGfdI/edit#gid=2100414436
  migration_csv_path = ENV["MIGRATION_CSV_PATH"] || Rails.root.join("db/data_migration/20230901000000_migrate_calls_for_evidence.csv")

  # Column headers to expect in the CSV
  column_for_document_id = "Document ID"
  column_for_path = "Path"

  # User ID to attribute the migration to in the document history (whodunnit)
  # Defaults to the user "GDS Inside Government Team"
  migration_user_id = ENV["MIGRATION_USER_ID"] || 406

  # Website base URL to use when verifying redirects exist
  # Defaults to the env var GOVUK_WEBSITE_ROOT which seems to exist in EKS
  base_url = ENV["GOVUK_WEBSITE_ROOT"] || "https://www.gov.uk"

  desc "Migrate Consultations to Calls for Evidence"
  task migrate: :environment do
    migration_csv = CSV.parse(File.read(migration_csv_path), headers: true)
    document_ids = migration_csv.map { |row| row[column_for_document_id] }
    whodunnit = User.find(migration_user_id)

    successes = []
    failures = []

    puts "\nMigrating #{document_ids.count} documents\n\n"

    document_ids.each do |document_id|
      document = Document.find(document_id)

      if document.latest_edition.is_a?(CallForEvidence)
        print "S" # skip; already migrated
        next
      end

      DataHygiene::MigrateConsultationToCallForEvidence.new(document:, whodunnit:).call
      successes << document_id
      print "."
    rescue StandardError => e
      failures << [document_id, e.message]
      print "F"
    end

    puts "\n\n"
    puts "Finished with #{successes.count} successful migrations and #{failures.count} failures."

    if failures.present?
      puts "\nDetails of failures (in CSV format):\n\n"
      puts ["Document ID", "Error message"].to_csv
      puts failures.map(&:to_csv)
    end
  end

  desc "Verify the migrated documents redirect as expected"
  task verify: :environment do
    migration_csv = CSV.parse(File.read(migration_csv_path), headers: true)
    documents = migration_csv.map do |row|
      {
        id: row[column_for_document_id],
        path: row[column_for_path],
      }
    end

    successes = []
    failures = []

    puts "\nVerifying redirects for #{documents.count} documents\n\n"

    documents.each do |document|
      consultation_path = document[:path]
      call_for_evidence_path = document[:path].sub("consultations", "calls-for-evidence")

      consultation = URI("#{base_url}#{consultation_path}")
      call_for_evidence = URI("#{base_url}#{call_for_evidence_path}")

      # Request the consultation URL
      response = Net::HTTP.get_response(consultation)
      unless response.code == "301"
        raise "Unexpected response code #{response.code} when requesting #{consultation}"
      end
      unless response["Location"] == call_for_evidence.path
        raise "Got redirected to #{response['Location']} but was expecting #{call_for_evidence}"
      end

      # Request the call for evidence URL
      response = Net::HTTP.get_response(call_for_evidence)
      unless response.code == "200"
        raise "Unexpected response code #{response.code} when requesting #{call_for_evidence}"
      end

      successes << document[:id]
      print "."
    rescue StandardError => e
      failures << [document[:id], e.message]
      print "F"
    end

    puts "\n\n"
    puts "Finished with #{successes.count} successful verifications and #{failures.count} failures."

    if failures.present?
      puts "\nDetails of failures (in CSV format):\n\n"
      puts ["Document ID", "Error message"].to_csv
      puts failures.map(&:to_csv)
    end
  end
end
