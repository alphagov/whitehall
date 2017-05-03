module Organisation::OrganisationSearchIndexConcern
  extend ActiveSupport::Concern

  included do
    after_update :update_search_index
  end

  def update_search_index
    if going_live_on_govuk?
      corporate_information_pages.each(&:update_in_search_index)
    elsif leaving_live_on_govuk?
      corporate_information_pages.each(&:remove_from_search_index)
    end
  end

private

  def going_live_on_govuk?
    govuk_status_changed? && govuk_status == 'live'
  end

  def leaving_live_on_govuk?
    govuk_status_changed? && govuk_status_was == 'live'
  end
end
