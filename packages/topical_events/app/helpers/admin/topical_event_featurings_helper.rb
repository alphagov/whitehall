module Admin::TopicalEventFeaturingsHelper
  def featuring_published_on(featuring)
    if featuring.offsite?
      (localize(featuring.offsite_link.date.to_date) if featuring.offsite_link.date) || ""
    else
      localize(featuring.edition.major_change_published_at.to_date)
    end
  end
end
