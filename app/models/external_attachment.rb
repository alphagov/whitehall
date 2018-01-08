class ExternalAttachment < Attachment
  include HasContentId

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

  # Is in OpenDocument format? (see https://en.wikipedia.org/wiki/OpenDocument)
  def opendocument?
    false
  end

  def file_extension
    ''
  end

  def name_for_link
    external_url
  end

  def could_contain_viruses?
    false
  end

  def external?
    true
  end

  def content_type
    'text/html'
  end

  def url(_options = {})
    external_url
  end

  def search_index
    {
      title: title,
    }
  end

  def readable_type
    'external'
  end
end
