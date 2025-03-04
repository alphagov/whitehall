# Remove old link check reports (and their links in the
# link_checker_api_report_links table). We have 12 million link
# check reports in the database and it slows the migration job down
# significantly. Keeping only reports from the beginning of the year
# drops this to a ballpark of 50k reports.

cut_off_point = Date.new(2025, 1, 1)
batch_size = 10_000
batch_count = 0

loop do
  # Fetch a batch of report IDs
  report_ids = LinkCheckerApiReport.where("created_at < ?", cut_off_point)
                                   .limit(batch_size)
                                   .pluck(:id)

  break if report_ids.empty? # Stop when no more records are left

  # Delete associated links first to satisfy foreign key constraints
  LinkCheckerApiReport::Link.where(link_checker_api_report_id: report_ids).delete_all

  # Now delete reports
  deleted_count = LinkCheckerApiReport.where(id: report_ids).delete_all

  batch_count += 1
  puts "Deleted batch #{batch_count} (#{deleted_count} reports and their links)"
end

puts "Completed deletion of old link check reports."
