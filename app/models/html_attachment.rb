class HtmlAttachment < Attachment
  extend FriendlyId

  include HasContentId

  has_one :govspeak_content,
          autosave: true,
          inverse_of: :html_attachment

  before_save :ensure_slug_is_valid

  validates :govspeak_content, presence: true
  validates_with GovspeakContactEmbedValidator

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
    options[:preview] = id if options[:preview]

    if options[:full_url]
      public_url(options)
    else
      public_path(options)
    end
  end

  def should_generate_new_friendly_id?
    safely_resluggable?
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
    slug || content_id
  end

  def base_path
    case attachable.path_name
    when "consultation_outcome"
      "/government/consultations/#{attachable.slug}/outcome/#{identifier}"
    when "consultation_public_feedback"
      "/government/consultations/#{attachable.slug}/public-feedback/#{identifier}"
    when "call_for_evidence"
      "/government/calls-for-evidence/#{attachable.slug}/#{identifier}"
    when "call_for_evidence_outcome"
      "/government/calls-for-evidence/#{attachable.slug}/outcome/#{identifier}"
    else
      "/government/#{attachable.path_name.pluralize}/#{attachable.slug}/#{identifier}"
    end
  end

  def publishing_api_presenter
    PublishingApi::HtmlAttachmentPresenter
  end

private

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    root = if options[:preview]
             Plek.external_url_for("draft-origin")
           else
             Plek.website_root
           end

    root + public_path(options)
  end

  # Sense-check that the title converted to ASCII contains more than just hyphens!
  def ensure_slug_is_valid
    return unless slug.present? && slug.count("A-Za-z") < 4

    # Force slug to be `nil` - but only if attachment isn't live already.
    # A `nil` slug will fall back to using the content_id as the slug.
    self.slug = nil if safely_resluggable?
  end
end
