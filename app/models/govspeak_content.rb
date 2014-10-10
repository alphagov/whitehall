class GovspeakContent < ActiveRecord::Base
  belongs_to :html_attachment, inverse_of: :govspeak_content

  validates :body, :html_attachment, presence: true
  validates_with SafeHtmlValidator

  before_save :reset_computed_html, if: :body_or_numbering_scheme_changed?
  after_save :queue_html_compute_job, if: :body_or_numbering_scheme_changed?

  def body_html
    computed_body_html.try(:html_safe)
  end

  def headers_html
    computed_headers_html.try(:html_safe)
  end

private

  # NOTE: we delay the processing of the govspeak so as to ensure that the
  # GovspeakContent record actually exists in the database. This is necessary
  # because the re-editioning process (which clones HtmlAttachments, and thus
  # GovspeakContent) takes a while, meaning the transaction may not have
  # completed before the job is picked up, causing ActiveRecord::RecordNotFound
  # errors.
  def queue_html_compute_job
    GovspeakContentWorker.perform_in(10.seconds, self.id)
  end

  def body_or_numbering_scheme_changed?
    body_changed? || manually_numbered_headings_changed?
  end

  def reset_computed_html
    self.computed_body_html = nil
    self.computed_headers_html = nil
  end
end
