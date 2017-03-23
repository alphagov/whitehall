namespace :db do
  desc "Report any data integrity issues"
  task :lint => :environment do
    require 'data_hygiene/orphaned_attachment_finder'
    o = DataHygiene::OrphanedAttachmentFinder.new
    $stderr.puts o.summarize_by_type
  end
end

namespace :data_hygiene do
  desc "Check Detailed Guides have a content item"
  task detailed_guide_content_items: :environment do
    not_found = 0
    published_guides = DetailedGuide.published

    published_guides.find_each do |guide|
      puts "--> Checking #{guide.content_id}"
      content_item = Services.publishing_api.get_content(guide.content_id)
      if content_item.present?
        puts "...found: #{content_item.base_path}"
      else
        not_found += 1
        puts "NOT FOUND"
      end
      puts
    end

    puts <<-REPORT.strip_heredoc
      ******************************
      *          SUMMARY           *
      ******************************
      total guides:       #{published_guides.count}
      no content item:    #{not_found}
      content item found: #{published_guides.count - not_found}
    REPORT
  end
end
