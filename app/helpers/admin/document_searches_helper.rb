module Admin::DocumentSearchesHelper
  def public_time_for_edition(edition)
    if edition.public_timestamp.present?
      render_datetime_microformat(edition, :public_timestamp) do
        edition.public_timestamp.to_date.to_s(:long_ordinal)
      end
    else
      "(#{edition.state.humanize})"
    end
  end
end
