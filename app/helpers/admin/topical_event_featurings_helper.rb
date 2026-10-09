# Legacy
module Admin::TopicalEventFeaturingsHelper
  def featuring_published_on(featuring)
    return "" if featuring.offsite?

    localize(featuring.edition.major_change_published_at.to_date)
  end
end
