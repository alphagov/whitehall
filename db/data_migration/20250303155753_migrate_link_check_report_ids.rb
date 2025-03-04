puts "Starting cleanup of old LinkCheckerApiReports..."

# Find all link_reportable_ids of Editions
link_reportable_ids = LinkCheckerApiReport.where(link_reportable_type: "Edition").pluck(:link_reportable_id).uniq
link_reportable_ids_count = link_reportable_ids.count

link_reportable_ids.each_with_index do |link_reportable_id, index|
  # Find the latest report for this link_reportable_id (keeping the one with the latest updated_at)
  latest_report = LinkCheckerApiReport.where(link_reportable_id: link_reportable_id, link_reportable_type: "Edition")
                                        .order(updated_at: :desc)
                                        .first

  # Find all reports for this link_reportable_id that are not the latest one
  reports_to_delete = LinkCheckerApiReport.where(link_reportable_id: link_reportable_id, link_reportable_type: "Edition")
                                          .where.not(id: latest_report.id)

  # Update the edition_id of the latest report to link_reportable_id
  latest_report.update!(edition_id: link_reportable_id)

  # Delete the associated links before deleting each report (this will respect the has_many :links association)
  reports_to_delete.each do |report|
    report.links.delete_all
    report.destroy!
  end

  puts "#{index + 1}/#{link_reportable_ids_count} - Edition ID #{link_reportable_id}: latest link_checker_api_report ID is #{latest_report.id} (updated at: #{latest_report.updated_at}). Deleted #{reports_to_delete.count} older reports."
end

puts "Finished cleanup of old LinkCheckerApiReports."
