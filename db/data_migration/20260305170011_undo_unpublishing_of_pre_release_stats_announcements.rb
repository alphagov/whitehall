incorrectly_unpublished_sas =
  StatisticsAnnouncement
    .unscoped
    .where(publishing_state: "unpublished")
    .where(updated_at: Date.new(2026, 2, 6).all_day)
    .includes(:publication, :statistics_announcement_dates)
    .select { |sa| sa.publication.blank? }
    .select do |sa|
      latest_release = sa.statistics_announcement_dates.max_by(&:release_date)&.release_date
      latest_release.present? && latest_release.future?
    end

incorrectly_unpublished_sas.each do |sa|
  sa.update!(redirect_url: nil, publishing_state: "published", current_release_date: sa.statistics_announcement_dates.last)
end
