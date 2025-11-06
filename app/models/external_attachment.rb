class ExternalAttachment < Attachment
  extend FriendlyId
  include HasContentId
  friendly_id { |config| config.routes = false }

  validates :external_url, presence: true, uri: true, length: { maximum: 255 }

  def accessible?
    true
  end

  def html?
    false
  end

  def pdf?
    false
  end

  def csv?
    false
  end

  def should_generate_new_friendly_id?
    false
  end

  # Is in OpenDocument format? (see https://en.wikipedia.org/wiki/OpenDocument)
  def opendocument?
    false
  end

  def file_extension
    ""
  end

  def name_for_link
    external_url
  end

  def external?
    true
  end

  def content_type
    "text/html"
  end

  def url(_options = {})
    external_url
  end

  def self.readable_type
    "external"
  end
end
