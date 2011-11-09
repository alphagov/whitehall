module GovspeakHelper

  def govspeak_to_admin_html(text)
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(anchor['href'])
      document, supporting_document = find_documents_from_uri(anchor['href'])
      if document.published?
        public_uri = rewritten_href_for_documents(document, supporting_document)
        anchor.replace %{<span class="published_link">#{anchor} <sup class="explanation">(<a class="public_link" href="#{public_uri}">public link</a>)</sup></span>}
      else
        inner_element = document.deleted? ? %{<del>#{anchor.inner_text}</del>} : anchor
        anchor.replace %{<span class="#{document.state}_link">#{inner_element} <sup class="explanation">(#{document.state})</sup></span>}
      end
    end
    doc.to_html.html_safe
  end

  def govspeak_to_html(text)
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(anchor['href'])
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

  def is_internal_admin_link?(href)
    uri = URI.parse(href)
    truncated_link_uri = [uri.host, uri.path.split("/")[1]].join("/")
    truncated_host_uri = [request.host, "admin"].join("/")
    truncated_link_uri == truncated_host_uri
  end

  def find_documents_from_uri(uri)
    id = uri[/\/([^\/]+)$/, 1]
    if uri =~ /\/supporting_documents\//
      supporting_document = SupportingDocument.find(id)
      document = supporting_document.document
    else
      document = Document.send(:with_exclusive_scope) { Document.find(id) }
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