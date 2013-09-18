module Admin::ImportHelper
  def force_publication_attempt_state_and_time(force_publication_attempt)
    "#{force_publication_attempt.status} #{render_datetime_microformat(force_publication_attempt, force_publication_attempt.status_timestamp_method) { force_publication_attempt.status_timestamp.to_s(:long)}}".html_safe
  end

  def awol_row_numbers(import)
    @awol_row_numbers ||= import.row_numbers - import.successful_row_numbers - import.failed_row_numbers
  end
end
