# Note that announcement pages are rendered by the `government-frontend` application.
class StatisticsAnnouncementsController < PublicFacingController
  include PublicDocumentRoutesHelper

  enable_request_formats(index: [:js])

  def index
    @filter = Frontend::StatisticsAnnouncementsFilter.new(filter_params)
    expire_cache_for_index_on_next_announcement_expiry(@filter.results)
    if request.xhr?
      skip_slimmer
      render partial: "statistics_announcements/filter_results"
    end
  end

private

  def filter_params
    params.permit!.to_h.slice(:page, :keywords, :from_date, :to_date, :organisations, :topics)
  end

  def expire_cache_for_index_on_next_announcement_expiry(announcements)
    time_to_releases = announcements.map { |ann| ann.release_date - Time.zone.now }.reject { |time_span| time_span <= 0 }
    expires_in((time_to_releases << Whitehall.default_cache_max_age).min)
  end
end
