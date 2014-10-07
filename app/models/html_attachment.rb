class HtmlAttachment < Attachment
  extend FriendlyId
  friendly_id :sluggable_string

  has_one :govspeak_content, autosave: true, inverse_of: :html_attachment

  before_validation :clear_slug_if_non_english_locale

  validates :govspeak_content, presence: true

  accepts_nested_attributes_for :govspeak_content
  delegate :body_html, :headers_html, :manually_numbered_headings?,
            to: :govspeak_content, allow_nil: true, prefix: true

  # Note: temporary setter to deal with the form submissions made with the old
  # code. To be cleaned up post-deploy.
  def body=(govspeak)
    (govspeak_content || self.build_govspeak_content).body = govspeak
  end

  # NOTE: temporary getter to make sure we still return body content before the
  # data has been migrated to the new delegated model
  def body
    govspeak_content.try(:body) || attributes['body']
  end

  def manually_numbered_headings?
    govspeak_content.try(:manually_numbered_headings?) || attributes['manually_numbered_headings']
  end

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

  # Is in OpenDocument format? (see http://en.wikipedia.org/wiki/OpenDocument)
  def opendocument?
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

  def search_index
    super.merge({
      content: extracted_text,
    })
  end

  def deep_clone
    super.tap do |clone|
      if govspeak_content.present?
        clone.govspeak_content = govspeak_content.dup
      end
    end
  end

  private

  def sluggable_locale?
    locale.blank? or locale == "en"
  end

  def sluggable_string
    sluggable_locale? ? title : nil
  end

  def clear_slug_if_non_english_locale
    if locale_changed? and !sluggable_locale?
      self.slug = nil
    end
  end
end
