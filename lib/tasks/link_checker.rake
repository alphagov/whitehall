namespace :link_checker do
  task delete_old_report_links: :environment do
    count = LinkCheckerApiReport::Link.deletable.delete_all
    puts "Deleted #{count} old report links."
  end
end
