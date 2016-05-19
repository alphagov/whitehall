class HtmlAttachment < Attachment
  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :attachable

  has_one :govspeak_content,
    autosave: true, inverse_of: :html_attachment, dependent: :destroy

  before_validation :clear_slug_if_non_english_locale

  validates :govspeak_content, presence: true

  accepts_nested_attributes_for :govspeak_content
  delegate :body, :body_html, :headers_html,
            to: :govspeak_content, allow_nil: true, prefix: true

  def manually_numbered_headings?
    govspeak_content.manually_numbered_headings?
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

  # Is in OpenDocument format? (see https://en.wikipedia.org/wiki/OpenDocument)
  def opendocument?
    false
  end

  def could_contain_viruses?
    false
  end

  def content_type
    'text/html'
  end

  def name_for_link
    'HTML attachment'
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
    Govspeak::Document.new(govspeak_content_body).to_text
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
      clone.slug = slug
      clone.govspeak_content = govspeak_content.dup
    end
  end

  def readable_type
    'HTML'
  end

  def save_and_update_publishing_api
    save && Whitehall.edition_services.draft_updater(attachable).perform!
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
