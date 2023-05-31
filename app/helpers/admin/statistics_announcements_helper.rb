module Admin::StatisticsAnnouncementsHelper
  def statistics_announcements_history_list(statistics_announcement)
    if statistics_announcement.cancelled?
      [
        tag.p("Announcement cancelled", class: "govuk-!-font-weight-bold govuk-!-margin-0 ") +
          tag.span(absolute_time(statistics_announcement.cancelled_at, class: "govuk-body-s app-view-statistics-announcements-history-entry__list-item-datetime") +
                     tag.span(" by ", class: " govuk-body-s app-view-statistics-announcements-history-entry__list-item-datetime") +
                     tag.span(statistics_announcement.cancelled_by ? linked_author(statistics_announcement.cancelled_by, class: "govuk-link govuk-body-s") : "User (removed)")),
      ]
    else
      statistics_announcement.statistics_announcement_dates.reverse.map do |previous_date|
        tag.p("Release date set to #{previous_date.display_date}", class: "govuk-!-font-weight-bold govuk-!-margin-0 ") +
          tag.span(absolute_time(previous_date.created_at), class: "govuk-body-s app-view-statistics-announcements-history-entry__list-item-datetime") +
          tag.span(" by ", class: " govuk-body-s app-view-statistics-announcements-history-entry__list-item-datetime") +
          tag.span(previous_date.creator ? linked_author(previous_date.creator, class: "govuk-link") : "User (removed)", class: " govuk-body-s")
      end
    end
  end
end
