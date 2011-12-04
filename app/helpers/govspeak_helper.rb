module GovspeakHelper

  def govspeak_to_admin_html(text)
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(anchor['href'])
      document, supporting_page = find_documents_from_uri(anchor['href'])
      if document.nil? || document.deleted?
        inner_text = "<del>#{anchor.inner_text}</del>"
        explanation = state = "deleted"
      else
        inner_text = anchor
        state = document.state
        if document.published?
          public_uri = rewritten_href_for_documents(document, supporting_page)
          explanation = %{<a class="public_link" href="#{public_uri}">public link</a>}
        else
          explanation = state
        end
      end
      html_fragment = %{<span class="#{state}_link">#{inner_text} <sup class="explanation">(#{explanation})</sup></span>}
      anchor.replace Nokogiri::HTML.fragment(html_fragment)
    end
    doc.to_html.html_safe
  end

  def govspeak_to_html(text)
    html = Govspeak::Document.to_html(text)
    doc = Nokogiri::HTML.fragment(html)
    doc.search('a').each do |anchor|
      next unless is_internal_admin_link?(anchor['href'])
      document, supporting_page = find_documents_from_uri(anchor['href'])
      if document && document.published?
        anchor['href'] = rewritten_href_for_documents(document, supporting_page)
      else
        anchor.replace anchor.inner_text
      end
    end
    doc.to_html.html_safe
  end

  def govspeak_headers(text, level = 2)
    Govspeak::Document.new(text).headers.each do |header|
      header.level == level
    end
  end

  private

  def is_internal_admin_link?(href)
    uri = URI.parse(href)
    return false unless %w(http https).include?(uri.scheme)
    truncated_link_uri = [uri.host, uri.path.split("/")[1,2]].join("/")
    truncated_host_uri = [request.host + Whitehall.router_prefix, "admin"].join("/")
    truncated_link_uri == truncated_host_uri
  end

  def find_documents_from_uri(uri)
    id = uri[/\/([^\/]+)$/, 1]
    if uri =~ /\/supporting_documents\//
      begin
        supporting_page = SupportingPage.find(id)
      rescue ActiveRecord::RecordNotFound
        supporting_page = nil
      end
      if supporting_page
        document = supporting_page.document
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
      supporting_page = nil
    end
    [document, supporting_page]
  end

  def rewritten_href_for_documents(document, supporting_page)
    if supporting_page
      policy_supporting_page_path(document, supporting_page)
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