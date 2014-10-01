class ExternalAttachment < Attachment
  validates :external_url, presence: true

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
    external_url
  end

  def search_index
    {
      title: title,
    }
  end
end
