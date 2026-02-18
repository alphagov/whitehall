namespace :statistics_announcements do
  desc "Unpublish statistics announcements and redirect them"
  # Usage:
  #   1. Create a file with one StatisticsAnnouncement ID and redirect url per line separated by ","
  #   2. Copy the file to a pod:
  #      $ kubectl cp ids.txt whitehall-admin-xxxxx:/tmp/ids.txt
  #   3. Run the task:
  #      $ kubectl exec whitehall-admin-xxxxx -- rake "statistics_announcements:unpublish_and_redirect[/tmp/ids.txt]"
  #
  task :unpublish_and_redirect, %i[file] => :environment do |_task, args|
    file = args[:file]

    unless file && File.exist?(file)
      puts "Usage: rake statistics_announcements:unpublish_and_redirect[file.txt]"
      next
    end

    statistics_announcements = File.readlines(file).map(&:strip).reject(&:empty?)

    puts "Found #{statistics_announcements.count} announcements to unpublish and redirect"
    print "Continue? (y/n): "
    next unless $stdin.gets.chomp.downcase == "y"

    success_count = 0
    failure_count = 0

    statistics_announcements.each do |document|
      id, redirect_url = document.split(",")

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
