# To address https://github.com/alphagov/whitehall/issues/6011, we need
# to remove old link checker reports and switch to a 'has_one' relationship.

Edition.find_each do |edition|
  reports = edition.link_check_reports.order(created_at: :desc).to_a
  next if reports.size <= 1

  # Keep the most recent report and delete the rest
  reports_to_delete = reports.drop(1)
  reports_to_delete.each(&:destroy)
end

