class GovspeakContent < ActiveRecord::Base
  belongs_to :html_attachment, inverse_of: :govspeak_content

  validates :body, :html_attachment, presence: true
  validates_with SafeHtmlValidator

  after_save :queue_html_compute_job, if: :body_changed?

  def body_html
    computed_body_html.try(:html_safe)
  end

  def headers_html
    computed_headers_html.try(:html_safe)
  end

private

  def queue_html_compute_job
    GovspeakContentWorker.perform_async(self.id)
  end
end
