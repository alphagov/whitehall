class HtmlAttachment < Attachment
  extend FriendlyId
  friendly_id :sluggable_string

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

  def csv?
    false
  end

  def could_contain_viruses?
    false
  end

  def content_type
    'text/html'
  end

  def url(options = {})
    options[:preview] = id if options.delete(:preview)

    path_helper = case attachable
                  when Consultation
                    :consultation_html_attachment_path
                  else
                    :publication_html_attachment_path
                  end
    Rails.application.routes.url_helpers.send(path_helper, attachable.slug, self, options)
  end

  def extracted_text
    Govspeak::Document.new(body).to_text
  end

  def should_generate_new_friendly_id?
    return false unless sluggable_locale?
    slug.nil? || attachable.nil? || !attachable.document.published?
  end

  private

  def sluggable_locale?
    locale.blank? or locale == "en"
  end

  def sluggable_string
    sluggable_locale? ? title : nil
  end
end
