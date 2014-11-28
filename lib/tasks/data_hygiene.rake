namespace :db do
  desc "Report any data integrity issues"
  task :lint => :environment do
    require 'data_hygiene/orphaned_attachment_finder'
    o = DataHygiene::OrphanedAttachmentFinder.new
    $stderr.puts o.summarize_by_type
  end
end

task :supporting_page_cleanup => :environment do
  require 'data_hygiene/supporting_page_cleaner'

  logger = Logger.new(Rails.root.join('log/supporting_page_cleanup.log'))

  Document.where(document_type: 'SupportingPage').find_each do |document|
    logger.info "Reparing: #{document.slug}"
    cleaner = SupportingPageCleaner.new(document, logger)
    if cleaner.needs_cleaning?
      cleaner.delete_duplicate_superseded_editions!
      cleaner.repair_version_history!
    end
  end
end

task :specialist_sector_cleanup => :environment do
  require "data_hygiene/specialist_sector_cleanup"

  puts "Which specialist sector is being deleted?"
  slug = STDIN.gets.chomp

  cleanup = SpecialistSectorCleanup.new(slug)

  if cleanup.any_taggings?
    puts "Some editions are tagged to #{slug}"

    if cleanup.any_published_taggings?
      puts "WARNING! Some documents have been published.  You will need to remove the sector from ElasticSearch"; puts
    end

    puts "What would you like to do?"
    puts "1. Untag the editions from the sector, adding an editorial note"
    puts "2. Untag the editions from the sector, no note"
    puts "3. Do nothing [default]"

    case STDIN.gets.chomp
    when "1"
      cleanup.remove_taggings(add_note: true)
    when "2"
      cleanup.remove_taggings(add_note: false)
    when "3", ""
      puts "Doing nothing"
      exit
    else
      puts "Invalid option"
      exit
    end
  else
    puts "The sector '#{slug}' has not been tagged to any editions"
  end
end

desc "Export csv for topic retagging"
task topic_retagging_csv_export: :environment do
  require "data_hygiene/tag_changes_exporter"

  csv_location = ENV['CSV_LOCATION']
  source_topic_id = ENV['SOURCE']
  destination_topic_id = ENV['DESTINATION']

  unless csv_location
    $stderr.puts "No location for output: please pass CSV_LOCATION"
    exit 1
  end

  if File.exists?(csv_location)
    $stderr.puts "Specified output file already exists; please remove it, or choose a different location"
    exit 1
  end

  unless source_topic_id
    $stderr.puts "No source topic: please pass SOURCE"
    exit 1
  end

  unless destination_topic_id
    $stderr.puts "No destination topic: please pass DESTINATION"
    exit 1
  end

  if source_topic_id == destination_topic_id
    $stderr.puts "Source and destination topics are the same"
    exit 1
  end

  TagChangesExporter.new(csv_location, source_topic_id, destination_topic_id).export
end

desc "Process csv for topic retagging"
task process_topic_retagging_csv: :environment do
  require "data_hygiene/tag_changes_processor"

  csv_location = ENV['CSV_LOCATION']

  unless csv_location
    $stderr.puts "No CSV path specified: please pass CSV_LOCATION"
    exit 1
  end

  TagChangesProcessor.new(csv_location).process
end
