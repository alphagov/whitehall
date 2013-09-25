class HtmlAttachment < Attachment
  extend FriendlyId
  friendly_id :title

  validates :body, presence: true
  validates_with SafeHtmlValidator

  def accessible?
    true
  end

  def html?
    true
  end

  def pdf?
    false
  end

  def could_contain_viruses?
    false
  end

  def content_type
    'text/html'
  end

  def url
    path_helper = case attachable
                  when Consultation
                    :consultation_html_attachment_path
                  else
                    :publication_html_attachment_path
                  end
    Rails.application.routes.url_helpers.send(path_helper, attachable.slug, self)
  end

  def extracted_text
  end
end
