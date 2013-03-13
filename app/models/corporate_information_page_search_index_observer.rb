class CorporateInformationPageSearchIndexObserver < ActiveRecord::Observer
  observe :organisation

  def after_update(org)
    if going_live_on_govuk?(org)
      org.corporate_information_pages.each(&:update_in_search_index)
    elsif leaving_live_on_govuk?(org)
      org.corporate_information_pages.each(&:remove_from_search_index)
    end
  end

  private
  def going_live_on_govuk?(org)
    org.govuk_status_changed? && org.govuk_status == 'live'
  end

  def leaving_live_on_govuk?(org)
    org.govuk_status_changed? && org.govuk_status_was == 'live'
  end

end
