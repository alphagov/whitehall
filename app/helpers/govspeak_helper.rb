module GovspeakHelper

  def govspeak_to_admin_html(text)
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(anchor['href'])
      document, supporting_document = find_documents_from_uri(anchor['href'])
      if document.nil? || document.deleted?
        inner_text = "<del>#{anchor.inner_text}</del>"
        explanation = state = "deleted"
      else
        inner_text = anchor
        state = document.state
        if document.published?
          public_uri = rewritten_href_for_documents(document, supporting_document)
          explanation = %{<a class="public_link" href="#{public_uri}">public link</a>}
        else
          explanation = state
        end
      end
      anchor.replace %{<span class="#{state}_link">#{inner_text} <sup class="explanation">(#{explanation})</sup></span>}
    end
    doc.to_html.html_safe
  end

  def govspeak_to_html(text)
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(anchor['href'])
      document, supporting_document = find_documents_from_uri(anchor['href'])
      if document && document.published?
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
    return false unless %w(http https).include?(uri.scheme)
    truncated_link_uri = [uri.host, uri.path.split("/")[1]].join("/")
    truncated_host_uri = [request.host, "admin"].join("/")
    truncated_link_uri == truncated_host_uri
  end

  def find_documents_from_uri(uri)
    id = uri[/\/([^\/]+)$/, 1]
    if uri =~ /\/supporting_documents\//
      begin
        supporting_document = SupportingDocument.find(id)
      rescue ActiveRecord::RecordNotFound
        supporting_document = nil
      end
      if supporting_document
        document = supporting_document.document
      else
        document = nil
      end
    else
      document = Document.send(:with_exclusive_scope) do
        begin
          Document.find(id)
        rescue ActiveRecord::RecordNotFound
          nil
        end
      end
      supporting_document = nil
    end
    [document, supporting_document]
  end

  def rewritten_href_for_documents(document, supporting_document)
    if supporting_document
      policy_supporting_document_path(document, supporting_document)
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