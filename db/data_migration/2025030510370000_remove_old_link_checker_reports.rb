# Now that we've switched over to using `edition_id` everywhere,
# let's - for the last time - remove all associated link check
# reports apart from the latest one. Otherwise, `edition.link_check_report`
# refers to the _oldest_ link check report, which is not what we want.
# In the next PR, we will add a uniqueness constraint on the `edition_id`
# in `link_checker_api_reports` table, after we've run this data migration.

puts "Starting cleanup of old LinkCheckerApiReports..."

edition_ids = LinkCheckerApiReport.distinct.pluck(:edition_id)
edition_ids_count = edition_ids.count

edition_ids.each_with_index do |edition_id, index|
  # Find the latest report for this edition_id (keeping the one with the latest updated_at)
  latest_report = LinkCheckerApiReport.where(edition_id:).order(updated_at: :desc).first

  # Find all reports for this edition_id that are not the latest one
  reports_to_delete = LinkCheckerApiReport.where(edition_id:).where.not(id: latest_report.id)

  # Delete the associated links before deleting each report (this will respect the has_many :links association)
  reports_to_delete.each do |report|
    report.links.delete_all
    report.destroy!
  end

  puts "#{index + 1}/#{edition_ids_count} - Edition ID #{edition_id}: latest link_checker_api_report ID is #{latest_report.id} (updated at: #{latest_report.updated_at}). Deleted #{reports_to_delete.count} older reports."
end

puts "Finished cleanup of old LinkCheckerApiReports."
