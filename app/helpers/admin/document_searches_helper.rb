module Admin::DocumentSearchesHelper
  def public_time_for_edition(edition)
    if edition.public_timestamp.present?
      absolute_date(edition.public_timestamp)
    else
      "(#{edition.state.humanize})"
    end
  end
end
