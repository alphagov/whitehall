namespace :statistics_announcements do
  desc "Unpublish statistics announcements and redirect them"
  # Usage:
  #   1. Create a file with one StatisticsAnnouncement ID per line
  #   2. Copy the file to a pod:
  #      $ kubectl cp ids.txt whitehall-admin-xxxxx:/tmp/ids.txt
  #   3. Run the task:
  #      $ kubectl exec whitehall-admin-xxxxx -- rake "statistics_announcements:unpublish_and_redirect[/tmp/ids.txt,https://www.gov.uk/government/statistics/redirect-page]"
  #
  task :unpublish_and_redirect, %i[file redirect_url] => :environment do |_task, args|
    file = args[:file]
    redirect_url = args[:redirect_url]

    unless file && File.exist?(file) && redirect_url
      puts "Usage: rake statistics_announcements:unpublish_and_redirect[file.txt,https://www.gov.uk/redirect]"
      next
    end

    ids = File.readlines(file).map(&:strip).reject(&:empty?)

    puts "Found #{ids.count} announcements to unpublish"
    puts "Will redirect to: #{redirect_url}"
    print "Continue? (y/n): "
    next unless $stdin.gets.chomp.downcase == "y"

    success_count = 0
    failure_count = 0

    ids.each do |id|
      announcement = StatisticsAnnouncement.unscoped.find(id)
      announcement.update!(publishing_state: "unpublished", redirect_url: redirect_url)
      puts "#{id} - #{announcement.title} - OK"
      success_count += 1
    rescue ActiveRecord::RecordNotFound
      puts "#{id} - NOT FOUND"
      failure_count += 1
    rescue StandardError => e
      puts "#{id} - ERROR: #{e.message}"
      failure_count += 1
    end

    puts "\nDone: #{success_count} success, #{failure_count} failed"
  end
end
