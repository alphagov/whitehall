namespace :db do
  desc "Report any data integrity issues"
  task :lint => :environment do
    require 'data_hygiene/orphaned_attachment_finder'
    o = DataHygiene::OrphanedAttachmentFinder.new
    $stderr.puts o.summarize_by_type
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

  TagChangesProcessor.new(csv_location, logger: Logger.new(STDOUT)).process
end

desc "Process CSV for topic tagging"
task process_topic_tagging_csv: :environment do
  require "data_hygiene/specialist_sector_tagger"

  csv_location = ENV['CSV_LOCATION']

  unless csv_location
    $stderr.puts "No CSV path specified: please pass CSV_LOCATION"
    exit 1
  end

  SpecialistSectorTagger.process_from_csv(csv_location, logger: Logger.new(STDOUT))
end

desc "Unwithdraw an edition (creates and publishes a draft with audit trail)"
task :unwithdraw_edition, [:edition_id] => :environment do |t,args|
  DataHygiene::EditionUnwithdrawer.new(args[:edition_id], Logger.new(STDOUT)).unwithdraw!
end

# This task must be removed once the move of detailed guides to /guidance
# is complete.
desc "Rename detailed guides in Rummager individually"
task :rummager_rename_detailed_guides => :environment do
  index = Whitehall::SearchIndex.for(:detailed_guides)
  live_specialist_sector_tag_slugs = nil
  scope = DetailedGuide.published
  count = scope.count
  i = 0

  scope.find_each do |dg|
    # This injects a pre-memoised set of slugs for live specialist sector tags
    # This is necessary as fetching these from Content API is expensive, and
    # unnecessary. The memoisation is scoped only to the Edition instance, which
    # is the correct behaviour in normal production running mode due to the
    # need to ensure the list is up to date. As this is a one-shot task which
    # will be removed, "external memoisation" seems like the most pragmatic
    # approach.
    # This saves approximately 1.5 seconds per published Detailed Guide, so
    # around an hour and a half.
    live_specialist_sector_tag_slugs ||=
      SpecialistSector.live_subsectors.map(&:slug)
    dg.instance_variable_set(:@live_specialist_sector_tag_slugs,
      live_specialist_sector_tag_slugs)

    index.add(dg.search_index)
    index.delete("/#{dg.slug}")
    puts "Renamed #{dg.slug} (#{i += 1}/#{count})"
  end
end
