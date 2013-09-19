module Admin::ImportHelper
  def force_publication_attempt_state_and_time(force_publication_attempt)
    "#{force_publication_attempt.status} #{render_datetime_microformat(force_publication_attempt, force_publication_attempt.status_timestamp_method) { force_publication_attempt.status_timestamp.to_s(:long)}}".html_safe
  end
end
