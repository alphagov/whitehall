module StatisticalReleaseAnnouncementFilterHelper
  def organisation_options_for_release_announcement_filter(selected_slug = nil)
    options_for_select(Organisation.with_statistical_release_announcements.alphabetical.map { |org| [org.name, org.slug] }.unshift(['All departments', nil]), Array(selected_slug))
  end

  def topic_options_for_release_announcement_filter(selected_slug = nil)
    options_for_select(Topic.with_statistical_release_announcements.alphabetical.map { |topic| [topic.name, topic.slug] }.unshift(['All topics', nil]), Array(selected_slug))
  end
end
