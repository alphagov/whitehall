module GovspeakHelper

  def govspeak_to_admin_html(text)
    r = Regexp.escape("http://test.host/admin")
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      document, supporting_document = find_documents_from_uri(anchor['href'])
      if document.published?
        public_uri = rewritten_href_for_documents(document, supporting_document)
        anchor.replace %{<span class="published_link">#{anchor} <sup class="explanation">(<a class="public_link" href="#{public_uri}">public link</a>)</sup></span>}
      else
        anchor.replace %{<span class="draft_link">#{anchor} <sup class="explanation">(draft)</sup></span>}
      end
    end
    doc.to_html.html_safe
  end

  def govspeak_to_html(text)
    r = Regexp.escape("http://test.host/admin")
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      document, supporting_document = find_documents_from_uri(anchor['href'])
      if document.published?
        anchor['href'] = rewritten_href_for_documents(document, supporting_document)
      else
        anchor.replace anchor.inner_text
      end
    end
    doc.to_html.html_safe
  end

  private

  def find_documents_from_uri(uri)
    id = uri[/\/([^\/]+)$/, 1]
    if uri =~ /\/supporting_documents\//
      supporting_document = SupportingDocument.find(id)
      document = supporting_document.document
    else
      document = Document.find(id)
      supporting_document = nil
    end
    [document, supporting_document]
  end

  def rewritten_href_for_documents(document, supporting_document)
    if supporting_document
      document_supporting_document_path(document, supporting_document)
    else
      case document
      when Speech
        public_document_path(document.becomes(Speech))
      else
        public_document_path(document)
      end
    end
  end
end