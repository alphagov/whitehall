require_relative "../publishing_api_presenters"

class PublishingApiPresenters::HtmlAttachment < PublishingApiPresenters::Item
  def links
    {
      parent: [
        parent.content_id
      ],
      organisations: parent.organisations.map(&:content_id),
    }
  end

private

  def document_format
    "html_publication"
  end

  def details
    {
      body: body,
      headings: headings,
      public_timestamp: public_timestamp,
      first_published_version: first_published_version?
    }
  end


  def base_path
    item.url
  end

  def description
    #not used in this format
  end

  def public_updated_at
    item.updated_at
  end

  def body
    ""
  end

  def headings
    govspeak_content.computed_headers_html
  end

  def first_published_version?
    parent.first_published_version?
  end

  def public_timestamp
    parent.public_timestamp
  end

  def parent
    item.attachable
  end

  def govspeak_content
    item.govspeak_content
  end
end
