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
