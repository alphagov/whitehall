namespace :link_checker do
  desc "Delete old link checker reports"
  task delete_old_data: :environment do
    link_count = LinkCheckerApiReport::Link.deletable.delete_all
    puts "Deleted #{link_count} old report links."
    report_count = LinkCheckerApiReport.no_links.delete_all
    puts "Deleted #{report_count} old reports"
  end
end
