class HtmlAttachment < Attachment
  extend FriendlyId

  include HasContentId

  has_one :govspeak_content,
          autosave: true,
          inverse_of: :html_attachment,
          dependent: :destroy

  before_validation :clear_slug_if_non_english_locale

  validates :govspeak_content, presence: true

  accepts_nested_attributes_for :govspeak_content
  delegate :body,
           :manually_numbered_headings?,
           to: :govspeak_content,
           allow_nil: true

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
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

  def content_type
    "text/html"
  end

  def name_for_link
    "HTML attachment"
  end

  def url(options = {})
    preview = options.delete(:preview)
    full_url = options.delete(:full_url)

    if preview
      options[:preview] = id
      options[:root] = Plek.external_url_for("draft-origin")
    else
      options[:root] = Plek.website_root
    end

    if full_url
      public_url(options)
    else
      public_path(options)
    end
  end

  def should_generate_new_friendly_id?
    return false unless sluggable_locale?

    slug.nil? || attachable.nil? || safely_resluggable?
  end

  def deep_clone
    super.tap do |clone|
      clone.slug = slug
      clone.content_id = content_id
      clone.govspeak_content = govspeak_content.dup
    end
  end

  def readable_type
    "HTML"
  end

  def translated_locales
    [locale || I18n.default_locale.to_s]
  end

  def identifier
    sluggable_locale? ? slug : content_id
  end

  def base_path
    case attachable.path_name
    when "consultation_outcome"
      "/government/consultations/#{attachable.slug}/outcome/#{identifier}"
    when "consultation_public_feedback"
      "/government/consultations/#{attachable.slug}/public-feedback/#{identifier}"
    else
      "/government/#{attachable.path_name.pluralize}/#{attachable.slug}/#{identifier}"
    end
  end

private

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    options[:root] + public_path(options)
  end

  def sluggable_locale?
    locale.blank? || (locale == "en")
  end

  def sluggable_string
    sluggable_locale? ? title : nil
  end

  def clear_slug_if_non_english_locale
    if locale_changed? && !sluggable_locale?
      self.slug = nil
    end
  end
end
